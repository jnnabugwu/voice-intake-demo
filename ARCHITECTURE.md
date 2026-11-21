# Architecture

Voice intake for care requests. A worker speaks in English or Spanish, sees their words live, and answers a few short follow-up questions. A physician reviews a structured summary and approves the next step before the worker sees it. A speech bench scores recognition engines on the same scripted care requests.

This document defines how the intake app and its proxy are built: the two sides, feature structure, layers, navigation, design system, state, data flow, and the contracts between them. `intake/CLAUDE.md` holds the build order and product guardrails; this file holds the shape the code must keep.

The app is also a working sample of the architecture proposed for a production mobile product. Nothing below is web-only. The same sides, folders, typed routes, Blocs and boundary checks carry over to iOS and Android builds. Only the engine adapters in `data/`, the choices in `bootstrap.dart`, and where the role comes from (a demo switch tonight, sign-in in production) change.

## At a glance

```
intake/app      Flutter web app: feature-first, Bloc + freezed, typed go_router routes, shadcn_ui. Runs with zero keys in demo mode.
intake/proxy    TypeScript functions on Vercel. Holds the Claude key, streams replies, builds summaries.
bench/          Shared scoring key (references.json), scorer, and results.
recorder/       Throwaway page that collected the bench clips. Not part of the product.
```

The design rests on one finding from the research: **speech quality depends on the recognition engine, not on the UI framework.** Flutter, native, and React Native all wrap the same system recognizers. So the engine sits behind one interface (`SpeechEngine`), and the bench decides which engine production should use.

## Two sides

The product has two kinds of user, and the code is split the same way.

| | Worker side | Physician side |
|---|---|---|
| Who | An employee asking for care, through their employer | The clinician who reviews it |
| Joins by | Signing up with their employer's code | An admin's invitation only |
| Sees | Their own intake only | The cases waiting for their review |
| Does | Speaks, answers follow-up questions, sees the approved next step | Reads the summary and transcript, edits the next step, approves |
| Layout | Phone: voice-first, one hand, large type | Tablet or desktop: keyboard, dense layout |
| Features | `speech`, `conversation`, `next_step` | `case_review` |

**Workers come through their employer.** Employers offer the app to their workers, so every worker and every case belongs to an employer, and the backend scopes access by it. Employers have no side in the app; the employer is a field on the account and the case, not a screen.

Both sides depend on `shared/`: the case entities and repository contracts, the safety detector, `Result` and `Failure`, and the design system. The sides never import each other. The case is the only thing they exchange, and they exchange it through `CaseRepository`: the worker side submits it, and the physician side approves it. A third folder, `internal/`, holds the speech bench. It ships in the demo build only. ("Demo build" means this demo app, as opposed to a production build. It is not demo *mode*: the deployed demo runs in live mode and keeps the bench and the side switch.)

To decide where code goes, ask: if the physician side were deleted, would this code go dead? If yes, it belongs to the physician side. If it would still be used, it belongs to the worker side or to `shared/`.

### One app, two roles

Both sides ship in one app: one store listing, one build, one release and one sign-in. What a person sees depends on their role.

**Tonight there is no sign-in.** A header switch, "Viewing as: Worker | Physician", moves between the sides. It exists only in the demo build. Both sides read the same `InMemoryCaseRepository`, so an approval on one side unlocks the next step on the other right away, with zero keys. The founder sees both sides from one link.

**In production the role comes from sign-in.**

- **Workers sign up themselves**, with their employer's code.
- **Physicians are invited by an admin and can't choose the role themselves.** Anyone who could pick "physician" at sign-up could read other people's cases. The physician role also requires MFA and shorter sessions. Workers don't carry that friction.
- **The server enforces the role.** It returns only the cases a user's role and employer allow. That is the security boundary.
- **The router mirrors the role.** It redirects each role to its own side, so a worker who opens a `/physician` link lands on `WorkerRoute`. This is a convenience on top of the server check, not a replacement for it.
- **The switch disappears.** The shell shows only the signed-in user's side.

Production also adds what tonight doesn't need: a backend case store with live updates behind the same `CaseRepository` interface, sign-in with roles and admin invitations, and push notifications.

**Why the sides stay walled off in code even in one app.** One app with roles tends to decay into one big router and screens duplicated per role in a flat folder, with each role's logic leaking into the other's. Here the sides never import each other, each owns its typed routes, and the boundary script enforces both. A reviewer can read one side without reading the other. If a clinic later needs a separate clinician app, for example one pushed to managed devices, the split is a packaging change and not a refactor.

## Structure: side, then feature, then layer

The code is grouped by side first, then by feature, then by layer. A feature is one concern a person can name, such as speech, the conversation or case review. Its folder holds everything that concern needs: entities, repositories, adapters, Blocs and pages. To learn how approval works, a reviewer opens `physician/features/case_review/` and finds all of it in one place, instead of searching across top-level `models/`, `services/` and `screens/` folders.

```
intake/app/lib/
  main.dart                    calls bootstrap()
  bootstrap.dart               composition root: picks the repositories; the only importer of data/
  app/                         the one place both sides meet
    app.dart                   ShadApp.router, demo/live badge
    router.dart                GoRouter: side shell around both sides' typed routes; role redirect
    side_shell.dart            the signed-in side's chrome; the "Viewing as" switch in the demo build
  worker/
    routes.dart                typed routes for /worker (+ routes.g.dart, committed)
    worker_screen.dart         composes this side's features + the escalation card
    features/
      speech/
        domain/                SpeechEngine, SpeechResult
        data/                  WebSpeechEngine
        presentation/          SpeechBloc, MicButton, LiveTranscript
      conversation/
        domain/                Turn, ChatChunk, ChatRepository, SubmitIntake
        data/                  DemoChatRepository, ProxyChatRepository, SSE parser
        presentation/          ConversationBloc, ChatList, ReplyBubble
      next_step/
        presentation/          NextStepBloc, NextStepCard
  physician/
    routes.dart                typed routes for /physician (+ routes.g.dart)
    features/
      case_review/
        presentation/          ReviewBloc, ReviewPage, SummaryPanel, ApprovePanel
  shared/                      both sides depend on it; it depends on neither
    core/                      Result, Failure, IDs
    ui/                        design system: theme, tokens, app components (ui.dart is the only import)
    features/
      intake_case/
        domain/                IntakeCase, CaseStatus, IntakeSummary, CaseRepository, SummaryRepository
        data/                  InMemoryCaseRepository, Demo/ProxySummaryRepository, IntakeSummaryDto
      safety/
        domain/                RedFlag, RedFlagDetector
        presentation/          EscalationCard (stateless)
  internal/
    routes.dart                typed route for /bench (+ routes.g.dart)
    features/
      bench/                   BenchBloc, BenchPage, JSON export
test/                          mirrors lib/: test/worker/..., test/physician/..., test/shared/...
```

### Rules

1. **Sides never import each other.** `worker/`, `physician/` and `internal/` import `shared/` and nothing else in `lib/`. `shared/` imports no side. Only `app/` sees more than one side.
2. **A feature is a folder.** To add a feature, add its folder under the side that uses it (or under `shared/features/` if both sides do), add its routes to that side's `routes.dart`, and add its repositories to `bootstrap.dart`. To remove one, delete those three things. If anything else has to change, a boundary has leaked.
3. **Features share domain types only.** A feature may import another feature's `domain/`, including shared ones. For example, `conversation` uses `shared/features/safety/domain` for `RedFlagDetector` and `shared/features/intake_case/domain` for `CaseRepository`. A feature never imports another feature's `data/` or `presentation/`.
4. **Each side composes its own screens.** A screen that belongs to one feature lives in that feature (`ReviewPage`, `BenchPage`). A screen that combines features lives at the side's root. `worker/worker_screen.dart` is the main one: mic, chat, next-step card and escalation card on one page, with the one `BlocListener` that hands speech to the conversation.
5. **Features don't know URLs.** Feature widgets take callbacks (`onCaseOpened`) and never import the router. Each side's `routes.dart` connects those callbacks to typed routes, so a feature can move to another app with different navigation without changing.
6. **`shared/` is earned.** Code moves there only once both sides use it. The repo has no catch-all `widgets/`, `utils/` or `models/` folder.

### Layers inside a feature

Every feature has up to three layers. Dependencies point inward.

| Layer | Holds | May import |
|---|---|---|
| `domain/` | freezed entities, repository interfaces, pure services (`RedFlagDetector`), use cases | Dart, `freezed_annotation`, `meta`, other features' `domain/`. No Flutter. |
| `data/` | Repository implementations, DTOs with `.toDomain()`, engine adapters | `domain/`, packages like `http` and `speech_to_text` |
| `presentation/` | Blocs, pages, widgets | `domain/`, `flutter_bloc`, `shared/ui/ui.dart`. **Never `data/`, never `shadcn_ui` directly.** |

`lib/bootstrap.dart` is the only file that imports `data/`. It is the composition root: it builds the repositories and passes them down through `MultiRepositoryProvider`.

### Checking the boundaries

`analysis_options.yaml` turns on `always_use_package_imports`, so every import names its side and feature and a grep can see it. `tool/check_boundaries.sh` runs every check and prints only violations. Run it before each commit; it must print nothing.

```sh
#!/bin/sh
# Prints every boundary violation. No output means clean.
cd "$(dirname "$0")/.."

# Sides
grep -rlE "package:intake/(physician|internal)/" lib/worker
grep -rlE "package:intake/(worker|internal)/" lib/physician
grep -rlE "package:intake/(worker|physician)/" lib/internal
grep -rlE "package:intake/(worker|physician|internal|app)/" lib/shared

# Layers
grep -rl "/data/" lib/*/features/*/presentation 2>/dev/null # presentation never imports data
grep -rl "package:flutter" lib/*/features/*/domain 2>/dev/null   # domain is pure Dart

# Features: none reaches into another's data/ or presentation/
for dir in lib/*/features/*/; do
  feature=${dir#lib/}; feature=${feature%/}                  # e.g. worker/features/speech
  grep -rHE "package:intake/[a-z_]+/features/[a-z_]+/(data|presentation)/" "$dir" \
    | grep -v "package:intake/$feature/"
done

# Routing
grep -rl "go_router" lib/*/features                          # features don't know URLs
grep -rnE "context\.(go|push|pushReplacement|replace)\(" lib --include='*.dart' --exclude='*.g.dart'   # no string paths

# Design system
grep -rlE "package:(flutter/material|flutter/cupertino|material_ui|cupertino_ui)" lib   # no Material or Cupertino
grep -rl "package:shadcn_ui" lib | grep -vE "^lib/(shared/ui|app)/"                  # the kit stays behind shared/ui
grep -rnE "Color\(0x|Colors\.|TextStyle\(" lib --include='*.dart' | grep -v "^lib/shared/ui/"   # colors and type come from the theme

# Data: only the composition root imports data/
grep -rlE "package:intake/[a-z_]+/features/[a-z_]+/data/" lib --include='*.dart' \
  | grep -vE "^lib/bootstrap\.dart$|^lib/[a-z_]+/features/[a-z_]+/data/"
```

Run the script before each commit; any output is a violation.

## Features and Blocs

One Bloc per concern. A Bloc that gathers a second concern gets split, not extended.

| Side | Feature | Bloc | Owns | Talks to |
|---|---|---|---|---|
| worker | `speech` | `SpeechBloc` | Mic status, locale, live partial text, the last final utterance | `SpeechEngine` |
| worker | `conversation` | `ConversationBloc` | Turns, the streaming reply, escalation, finishing the intake | `ChatRepository`, `RedFlagDetector`, `SubmitIntake` |
| worker | `next_step` | `NextStepBloc` | The worker's locked or unlocked next step | `CaseRepository` (watch only) |
| physician | `case_review` | `ReviewBloc` | The physician's view of the case: summary, edits, approval | `CaseRepository` |
| internal | `bench` | `BenchBloc` | The current bench line, timestamps, JSON export | its own `SpeechEngine` |
| shared | `intake_case` | none | The case entities and the `CaseRepository` / `SummaryRepository` contracts | |
| shared | `safety` | none | `RedFlagDetector`, a pure function over text and language | |

Cubits are reserved for local UI state that never touches a repository, such as a collapsed panel or a text field's draft.

### Data flow

```
 Worker side                                            Physician side

 SpeechBloc ──final utterance──▶ ConversationBloc
     │        (BlocListener on       │   1. RedFlagDetector (before any model call)
     │         WorkerScreen)         │   2. ChatRepository.reply()  ── Demo | Proxy
     ▼                               │   3. SubmitIntake on finish
 SpeechEngine                        ▼
 (Web Speech today)          SummaryRepository ──▶ CaseRepository (in memory)
                                                     ▲                ▲
                                        NextStepBloc ┘                └ ReviewBloc
                                        (watch: locked                (watch, approve,
                                         until approved)               edit next step)
                                        ─────────── shared/: the only line between the sides ───────────
```

Blocs never hold references to each other. Coordination happens in two places only:

1. **A `BlocListener` on `WorkerScreen`** forwards one Bloc's output to another Bloc as a named event. The speech-to-conversation hand-off is the only such hand-off. It lives at the worker side's root because it spans two of that side's features.
2. **A shared repository stream.** `CaseRepository` holds the one copy of the case, and it is the only channel between the sides. `ReviewBloc` writes to it; `NextStepBloc` watches it. Nothing else keeps a second copy of "is this approved?" Tonight the stream is in memory. In production it is the backend's live case feed, and neither side's code changes.

### Single sources of truth

| Fact | Lives in | Everyone else |
|---|---|---|
| The transcript while gathering | `ConversationBloc` state | reads it from that state |
| The case after submission (summary, status, next step) | `CaseRepository` | watches the stream |
| Mic status | `SpeechBloc` state | reads it from that state |
| Demo or live mode | `bootstrap.dart` (from `PROXY_URL`) | receives the chosen repositories |
| Which side and screen is showing | The URL, parsed by the typed route | read from the route's fields, never from a Bloc |

Two objects that each keep their own copy of a fact will drift. Derive from one source instead.

## Navigation: typed routes

Navigation uses `go_router` with `go_router_builder`. Every route is a class. Its path, parameters and parameter types are declared once, and the generator writes the parsing and the location builder. A call site can't misspell a path, leave out a parameter, or pass a string where an `int` belongs, because the compiler rejects it. Hand-written path strings appear only in the annotations in each side's `routes.dart`.

**Each side owns its routes.** `worker/routes.dart`, `physician/routes.dart` and `internal/routes.dart` each declare a typed route tree, and each generates its own `routes.g.dart`. No side's routes import another side's.

| Side | Route class | Path | Parameters | Builds |
|---|---|---|---|---|
| worker | `WorkerRoute` | `/worker` | | `WorkerScreen`, providing `SpeechBloc`, `ConversationBloc`, `NextStepBloc` |
| physician | `ReviewRoute` | `/physician` | | `ReviewPage` for the current case |
| physician | `CaseRoute` | `/physician/cases/:caseId` | `caseId` (path) | `ReviewPage` for one case |
| internal | `BenchRoute` | `/bench` | `line` (query, `int?`) | `BenchPage`, starting at that line |

`/` redirects to `WorkerRoute`. An unknown path shows the error page, which links back to it.

```dart
// lib/physician/routes.dart
part 'routes.g.dart';

@TypedGoRoute<ReviewRoute>(
  path: '/physician',
  routes: [TypedGoRoute<CaseRoute>(path: 'cases/:caseId')],
)
class ReviewRoute extends GoRouteData with $ReviewRoute {
  const ReviewRoute();
  // build: ReviewBloc on CaseRepository.watchCurrent()
}

class CaseRoute extends GoRouteData with $CaseRoute {
  const CaseRoute({required this.caseId});

  final String caseId; // path parameter

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
        create: (context) => ReviewBloc(context.read<CaseRepository>())..add(ReviewOpened(caseId)),
        child: ReviewPage(onCaseOpened: (id) => CaseRoute(caseId: id).go(context)),
      );
}
```

```dart
// lib/internal/routes.dart
part 'routes.g.dart';

@TypedGoRoute<BenchRoute>(path: '/bench')
class BenchRoute extends GoRouteData with $BenchRoute {
  const BenchRoute({this.line});

  final int? line; // query parameter: /bench?line=7

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
        create: (context) => BenchBloc(context.read<SpeechEngine>(), startLine: line),
        child: const BenchPage(),
      );
}
```

**Only `app/` combines the sides.** `app/router.dart` wraps the two sides' generated routes in a `StatefulShellRoute`, so each side keeps its own navigator. The bench sits outside the shell and is reached by URL. The shell declares no paths, so the typed routes stay the only source of URLs.

```dart
// lib/app/router.dart (demo build)
import 'package:intake/internal/routes.dart' as internal;
import 'package:intake/physician/routes.dart' as physician;
import 'package:intake/worker/routes.dart' as worker;

final appRouter = GoRouter(
  initialLocation: const worker.WorkerRoute().location,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => SideShell(shell: shell), // "Viewing as: Worker | Physician"
      branches: [
        StatefulShellBranch(routes: [worker.$workerRoute]),
        StatefulShellBranch(routes: [physician.$reviewRoute]),
      ],
    ),
    internal.$benchRoute,
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
```

In production, the same router makes three changes:

- It gains a `redirect` that reads the signed-in role from the session. A worker on a physician route goes to `WorkerRoute`, a physician on a worker route goes to `ReviewRoute`, and a signed-out user goes to sign-in.
- `SideShell` drops the switch and shows only the user's side.
- The bench routes are left out of the build.

Call sites use the class, never a string:

```dart
const CaseRoute(caseId: 'c_42').go(context);   // not context.go('/physician/cases/c_42')
const BenchRoute(line: 7).go(context);          // not context.go('/bench?line=7')
```

### Routing rules

- **URLs carry IDs, never objects.** No `$extra`. On web, `extra` is lost on refresh; on mobile, it can't come from a push notification or a deep link. A route takes a `caseId` and its Bloc loads the case from `CaseRepository.watch(caseId)`.
- **Routes scope Blocs.** A route's `build` provides the Blocs its screen needs and nothing else, so each Bloc's lifetime follows the route. `StatefulShellRoute` keeps each side's navigator alive, so switching to the physician side mid-intake doesn't close the worker's `ConversationBloc` or drop the mic.
- **Safety and approval are state, not routes.** The escalation card and the locked next step render from Bloc state on `WorkerScreen`. They are not pushed routes, so the back button or an edited URL can't dismiss an emergency card or reach an unapproved next step.
- **Bad parameters degrade, they don't crash.** Optional query parameters are nullable, and the Bloc clamps them (`/bench?line=99` opens the last line). A path that doesn't parse goes to the error page.
- **Generated code is committed**, like freezed output. `routes.g.dart` is regenerated with the same `dart run build_runner build`.

On mobile, the same route classes serve the deep links that production needs. A worker's notification that a next step is approved opens `WorkerRoute`. A physician's notification that a case needs review opens `CaseRoute(caseId: …)`, and the role redirect makes sure only a physician gets there. Both are parsed and type-checked by the same generated code. Android's back button follows the route stack with no extra code.

## Design system: shadcn_ui

The UI is built with [`shadcn_ui`](https://pub.dev/packages/shadcn_ui), the Flutter port of shadcn/ui, and uses no Material or Cupertino widgets. The look is calm, neutral and dense with information, which suits a clinical tool better than stock Material. The kit has 160/160 pub points, an MIT license, and support for all six platforms. It ships Spanish strings among 70+ built-in locales, and its theme is a single typed object.

### Setup

```dart
// lib/app/app.dart
ShadApp.router(
  routerConfig: appRouter,                       // the typed GoRouter
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,                      // follows the system setting
  builder: (context, child) => DemoBadge(child: child!),
)
```

`ShadApp` puts `ShadToaster` and `ShadSonner` in the tree and registers `GlobalShadLocalizations` itself. Plain `ShadApp` builds a `WidgetsApp` rather than a `MaterialApp`, so the boundary script bans Material and Cupertino imports anywhere in `lib/`. A Material widget would render unthemed.

**Version policy.** The package is pre-1.0 and ships breaking changes: 0.60.0 moved to the `material_ui` packages and raised the Flutter floor to 3.47. Pin an exact version in `pubspec.yaml` (`shadcn_ui: 0.61.2`, with no `^`). Upgrade in a commit of its own, after reading the changelog. Only `shared/ui/` and `app/app.dart` import the package, so an upgrade, or a swap to another kit, touches those two places and nothing in the sides.

### Tokens

Screens never name a color, font size or hex value. They read the theme. The boundary script bans `Color(0x…)`, `Colors.` and raw `TextStyle(` everywhere outside `lib/shared/ui/`.

- **Base palette:** `ShadSlateColorScheme.light()` and `.dark()`. Slate's cool neutrals keep the screen quiet, so the few status colors stand out.
- **Semantic tokens** sit on top of the base palette, in the scheme's `custom` map. Features read them through one extension, `context.tokens`:

  | Token | Means | Used by |
  |---|---|---|
  | `listening` | The mic is live | `MicButton` ring, `LiveTranscript` caret |
  | `pending` | Waiting on a clinician | Locked `NextStepCard`, review badge |
  | `approved` | A clinician approved this | Unlocked `NextStepCard`, toast |
  | `escalation` | Emergency or crisis | `EscalationCard` (with the base `destructive`) |

  A status is never shown by color alone. Each token always comes with an icon and a word ("Waiting for a clinician", "Approved").
- **Typography:** `ShadTheme.of(context).textTheme` with its default font, Geist. Transcript text uses `large`, so a worker can read it from arm's length. Partial words use `muted` until they turn final. Physician fields use `p` and `small`. Spanish runs about 25% longer than English, so no layout fixes a text width.
- **Icons:** `LucideIcons`, which ship with `shadcn_ui`. There is no second icon set.

### Screens and components

Screens use the app's own components from `shared/ui/ui.dart` and never import `shadcn_ui`; the boundary script enforces this. Each app component is a thin widget over a shadcn component. Its API is named for what it means in this product, not for the kit's options, and it wraps only what the screens use:

| App component (`shared/ui`) | Built on | API |
|---|---|---|
| `AppButton` | `ShadButton` variants | `.primary`, `.secondary`, `.outline`, `.quiet`, `.danger`; 48 dp tall |
| `AppIconButton` | `ShadButton` (round) | icon plus a spoken label; the 72 dp mic |
| `AppBadge` | `ShadBadge` | word plus optional icon and token color; `.outline`, `.danger` |
| `AppCard` | `ShadCard` | title, description, child, footer |
| `StatusBadge` | `ShadBadge` | takes a `CaseStatus`: picks the token, icon and word itself |
| `AppAlert` | `ShadAlert` | `.info`, `.danger` |
| `AppTextField`, `AppTextArea` | `ShadInput`, `ShadTextarea` | |
| `AppSegmented` | `ShadToggleGroup` | the EN/ES toggle |
| `showAppToast` | `ShadSonner` | message plus an optional Retry action |

A composite such as `EscalationCard` lives with its feature, built from these. The table below names the shadcn component inside each app component, so a reader can match the screens to the kit's docs.

| Screen / widget | Built from | Notes |
|---|---|---|
| `SideShell` switch (demo build) | `ShadButton.ghost` row, the active side `ShadButton.secondary` | "Viewing as: Worker \| Physician". Calls `shell.goBranch(i)` |
| Demo notice | `ShadAlert` + `ShadBadge` ("Demo" / "Live") | "Demo, don't enter real health information." Always visible |
| `MicButton` | `ShadButton` with `LucideIcons.mic`, 72 dp | Ring pulses in `listening` (`flutter_animate`). Pulse stops under reduced motion |
| Language toggle | `ShadToggleGroup` with EN and ES | Sets the speech locale and the UI language together |
| `LiveTranscript` | `textTheme.large` / `muted` | Semantics live region, so screen readers announce final text |
| Chat bubbles | `ShadCard`, assistant on `colorScheme.muted` | The streaming reply shows a caret, not a spinner |
| Typed fallback | `ShadInput` + `ShadButton` | Shown when speech is unavailable. Sends `TypedMessageSubmitted` |
| `NextStepCard` | `ShadCard` | Locked: `pending`, lock icon, no content. Unlocked: `approved`, the next step |
| `EscalationCard` | Full-screen page: `ShadAlert.destructive` + `ShadButton.destructive` "Call 911" / "Call or text 988" | `tel:` / `sms:` links. Not a dialog, so a tap outside can't dismiss it |
| `ReviewPage` | `ShadCard` per summary group, `ShadBadge` for severity, `ShadBadge.destructive` per red flag, `ShadAccordion` for the transcript | Null fields read "Not mentioned" in `muted` and are never left blank |
| Approve / Edit | `ShadButton` / `ShadButton.outline`, edit in `ShadTextarea` | A `ShadSonner` toast confirms approval |
| `BenchPage` | `ShadCard` for the line, `ShadProgress` for *n* of 21, `ShadButton.outline` to export | Timestamps in `small` |

### Errors in the UI

The screen picks the surface by switching on the `Failure` type, so it never reads message text:

| Failure | Surface |
|---|---|
| `NetworkFailure`, `RateLimitedFailure` | `ShadSonner` toast with a Retry action that sends `ReplyRetryRequested` |
| `SpendCapFailure` | Inline `ShadAlert`: the live demo is paused for today, try demo mode |
| `MicPermissionFailure`, `SpeechUnavailableFailure` | Inline `ShadAlert` above the typed fallback, explaining why and saying "Best in Chrome" |
| `UnknownFailure` | Toast with Retry |

A toast is for something the worker can retry. An inline alert is for a state that holds until something changes.

### Accessibility

The kit has no published accessibility audit, so the app owns accessibility and tests it.

- Every tap target is at least 48 dp. The mic button is 72 dp.
- Text scales up to 200% (`MediaQuery.textScaler`) without clipping.
- The mic button announces its state ("Start listening", "Listening, tap to stop"). The escalation card takes focus and is announced when it appears.
- Reduced motion (`MediaQuery.disableAnimations`) turns off the mic pulse and toast slides.
- Widget tests check Flutter's `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` and `textContrastGuideline` on every screen, in light and dark, in English and Spanish.

## State and models: freezed

- **Bloc states are sealed unions, generated by freezed.** Each variant is one phase a screen can be in, and it carries only the data that phase has:

  ```dart
  @freezed
  sealed class SpeechPhase with _$SpeechPhase {
    const factory SpeechPhase.idle() = SpeechIdle;
    const factory SpeechPhase.starting() = SpeechStarting;
    const factory SpeechPhase.listening({required String partial}) = SpeechListening;
    const factory SpeechPhase.unavailable({required Failure failure}) = SpeechUnavailable;
  }
  ```

  The UI switches on the phase, and the compiler requires every variant to be handled. (`SpeechState` holds `language` and `lastUtterance` beside this `phase`; see the next point.)

  ```dart
  return switch (state.phase) {
    SpeechIdle() => MicButton.idle(onTap: start),
    SpeechStarting() => const MicButton.starting(),
    SpeechListening(:final partial) => LiveTranscript(partial: partial),
    SpeechUnavailable(:final failure) => TypedFallback(reason: failure),
  };
  ```

- **Data that spans phases sits beside a sealed phase.** This applies when some data must survive every phase. The conversation's turns stay on screen while a reply streams, fails, retries or escalates. That state is a freezed class holding the shared data plus a sealed `phase`. No field can carry over by mistake from one phase into another:

  ```dart
  @freezed
  abstract class ConversationState with _$ConversationState {
    const factory ConversationState({
      @Default(<Turn>[]) List<Turn> turns,
      @Default(ConversationPhase.gathering()) ConversationPhase phase,
    }) = _ConversationState;
  }

  @freezed
  sealed class ConversationPhase with _$ConversationPhase {
    const factory ConversationPhase.gathering() = Gathering;
    const factory ConversationPhase.streaming({required String turnId, required String reply}) = Streaming;
    const factory ConversationPhase.replyFailed({required String turnId, required Failure failure}) = ReplyFailed;
    const factory ConversationPhase.redFlagRaised({required RedFlag flag}) = RedFlagRaised;
    const factory ConversationPhase.finished() = Finished;
  }
  ```

  | Bloc | State shape |
  |---|---|
  | `SpeechBloc` | `language` and `lastUtterance` plus a sealed `phase`: idle, starting, listening(partial), unavailable(failure) |
  | `NextStepBloc` | Sealed: none (nothing submitted yet), locked, unlocked(nextStep), escalated(flag), where escalated wins whenever the case has a red flag |
  | `ReviewBloc` | Sealed: loading, noCase, ready(case, draft, approving, approveFailure) |
  | `ConversationBloc` | `turns` plus a sealed `phase` |
  | `BenchBloc` | One class: line index and timestamps, with no exclusive phases |

  A new attempt moves to a new variant, so a stale error or a half-streamed reply can't survive it.

  **Why sealed:** a failure exists only on the failed variant, so a state like "gathering, with an old error still set" can't be built. When someone adds a variant, the compiler lists every screen that doesn't handle it yet.

  **Why freezed generates the states rather than hand-written classes:** Bloc skips an emitted state that is equal to the current one, and `bloc_test` compares expected states by value, so states need value equality. Hand-written states get it from `Equatable`. A field left out of its `props` makes two different states compare equal, and Bloc then drops the emit without an error. In this app, that dropped emit could be "approved, unlock the next step." freezed's generated equality covers every field, compares lists deeply, and returns collections unmodifiable. The build already runs freezed for entities and DTOs, so this adds no new tool.
- **Entities are freezed classes** too, with classic constructors and the `abstract` or `sealed` keyword.
- **Closed sets of outcomes are sealed unions.** Use them for engine output, chat chunks, and case status, and handle them with `switch`. The compiler flags a missed case. Use `switch` rather than `.when`.

  ```dart
  @freezed
  sealed class CaseStatus with _$CaseStatus {
    const factory CaseStatus.awaitingReview() = AwaitingReview;
    const factory CaseStatus.approved({required String nextStep}) = Approved;
  }
  ```
- **Events are plain sealed classes**, hand-written with no codegen. They are named after what happened (`UtteranceSubmitted`, `ApproveRequested`), one class per event, so the event vocabulary is greppable. Bloc never compares events, so they don't need generated equality the way states do.
- **Wire formats are DTOs in `data/`** (freezed + `json_serializable`), mapped with `.toDomain()`. Domain entities never get `fromJson`.
- **`Result` and `Failure` are hand-written sealed classes**, not freezed. They live in `lib/shared/core/`. Each `Failure` subtype overrides `==` and `hashCode`, because states that hold a failure compare by value. They hold a code at most, so this is a few lines each.
- **Generated files are committed** (`*.freezed.dart`, `*.g.dart`). A fresh clone runs `flutter run -d chrome` without `build_runner`. After changing any annotated class, run `dart run build_runner build` and commit the output in the same commit.

## Errors

Repositories return `Result<T>` (`Ok` or `Err(Failure)`); they never throw across the layer boundary. Every repository method that returns a `Result` carries `@useResult`, so the analyzer flags a call site that discards it. A discarded `Result` is a failure the user never sees.

```dart
abstract interface class CaseRepository {
  Stream<IntakeCase?> watchCurrent();
  Stream<IntakeCase?> watch(String caseId);

  @useResult
  Future<Result<void>> approve(String caseId, {required String nextStep});
}
```

`Failure` is a sealed class: `NetworkFailure`, `RateLimitedFailure`, `SpendCapFailure`, `MicPermissionFailure`, `SpeechUnavailableFailure`, `UnknownFailure`. The UI picks its message by switching on the type, never by reading message text.

**Streams end with a value, not an error.** `ChatRepository.reply()` and `SpeechEngine.listen()` catch their own errors and emit a terminal `ChatChunk.failed(failure)` or `SpeechResult.failed(failure)`. A Bloc's `emit.forEach` subscription ends on its first stream error, so an error that escapes leaves the screen stuck. Each stream-backed Bloc also has a retry event (`ReplyRetryRequested`, `SpeechStarted`) that resubscribes.

## Concurrency

Bloc processes events of the same type concurrently by default. Every handler that writes or starts a stream declares its transformer (`bloc_concurrency`):

| Bloc | Event | Transformer | Why |
|---|---|---|---|
| `SpeechBloc` | `SpeechStarted` | `droppable` | A second tap while the mic starts does nothing |
| `ConversationBloc` | `UtteranceSubmitted`, `TypedMessageSubmitted` | `droppable` | One reply at a time; the UI disables input while a reply streams, so nothing is dropped silently |
| `ConversationBloc` | `ReplyRetryRequested` | `droppable` | A second tap is ignored while the retry runs. `restartable` would cancel the retry in flight and strand the phase on `streaming` |
| `ReviewBloc` | `ApproveRequested` | `droppable` | A double tap can't approve twice |

**Stable IDs make retries safe.** Each utterance and each turn has an ID created once, when it is first submitted. A retry reuses the turn ID, and the proxy and `ConversationBloc` ignore a turn ID they have already answered.

## Safety path

1. **Before any model call**, `ConversationBloc` runs `RedFlagDetector` on the new text in the conversation's language. A hit stops the chat, submits the case with `IntakeCase.redFlag` set, and shows the full-screen card: 911 for emergencies and 988 for crisis, in the worker's language.
2. **After the summary**, a non-empty `red_flags` list in the summary also escalates.
3. **A refusal** from the model (`ChatChunk.refused`) shows "Let me connect you with a clinician" and offers the 911 and 988 lines as buttons (`HelpLines`). The chat continues; a refusal isn't an emergency.
4. **The proxy checks again.** It runs the same EN/ES patterns on the newest message before calling the model and answers with a `red_flag` event (`ChatChunk.redFlag`), which escalates like step 1. This covers any client that skips the app's check.

An escalated case reaches the physician at once with `IntakeCase.redFlag` set, and the review page says what the worker was shown and what triggered it. The flag is a record, separate from `status`, so approving a follow-up keeps it for the physician. On the worker's side the card holds until a clinician approves a next step for that case; the approved step then replaces the card, with the 911 and 988 buttons still offered under it. Both pattern lists are tested against every line of `bench/references.json` in both languages: lines 20 (chest pain) and 21 (new confusion in an older adult with diabetes, asking about the ER) escalate, and 1–19 don't.

`RedFlagDetector` is pure Dart with English and Spanish phrase lists, checked in both languages on every message because workers mix them. It has no network and no model, so it works in demo mode and offline.

## Demo mode and live mode

`bootstrap.dart` reads `const String.fromEnvironment('PROXY_URL')`.

| | Demo mode (no `PROXY_URL`) | Live mode |
|---|---|---|
| `ChatRepository` | `DemoChatRepository`: scripted replies chosen by keywords, streamed word by word | `ProxyChatRepository`: SSE from `/api/chat` |
| `SummaryRepository` | `DemoSummaryRepository`: built from the transcript by keyword rules | `ProxySummaryRepository`: `/api/summary` |
| `CaseRepository` | `InMemoryCaseRepository` in both modes | |
| `SpeechEngine` | `WebSpeechEngine` (`speech_to_text`, Chrome's Web Speech API) in both modes | |

Both modes render identical screens; a badge shows which one is running. The two sides share one app instance, and the header switch moves between them. Two browser tabs do not share state.

When `SpeechRecognition` is missing (Firefox, Brave, some in-app browsers), `SpeechBloc` reports `SpeechUnavailableFailure`. The worker view then explains why and offers typed input, which sends `TypedMessageSubmitted` through the same path.

## Proxy

```
intake/proxy/
  api/chat.ts        POST, streams the reply as SSE
  api/summary.ts     POST, returns IntakeSummary JSON (structured outputs)
  lib/claude.ts      Anthropic SDK client; model from CLAUDE_MODEL
  lib/guards.ts      CORS allowlist, per-IP rate limit, daily spend cap
  lib/sse.ts         SSE framing
  prompts/           one file per system prompt, readable by a reviewer
  contract/          summary.example.json, the shared fixture
```

The proxy logs metadata only (status, latency, token counts) and never the transcript. The rate limit and spend counters are per instance and best effort. The hard ceiling is the spend limit on the Claude Console workspace.

### Wire contract

`POST /api/chat`

```json
{ "conversationId": "c_…", "turnId": "t_…", "language": "en|es",
  "messages": [{ "role": "user|assistant", "text": "…" }] }
```

The response is `text/event-stream` with five event types. The app maps each to a `ChatChunk`.

| SSE event | Data | `ChatChunk` |
|---|---|---|
| `delta` | `{ "text": "…" }` | `ChatChunk.delta` |
| `done` | `{}` | `ChatChunk.done` |
| `refusal` | `{}` | `ChatChunk.refused` |
| `red_flag` | `{ "kind": "emergency" \| "crisis" }` | `ChatChunk.redFlag`: the proxy's own keyword pass on the newest message, before any model call (defense in depth behind the app's `RedFlagDetector`) |
| `error` | `{ "code": "rate_limited" \| "spend_cap" \| "upstream" }` | `ChatChunk.failed` |

`POST /api/summary` takes `{ conversationId, language, transcript }` and returns the summary: `chief_complaint`, `duration`, `severity` (1–10 or null), `symptoms[]`, `medications[]`, `allergies[]`, `red_flags[]`, `language`, `open_questions[]`, `transcript`. A field is null when the worker didn't say it. The model never infers one.

Status codes: `429` with `code` set to `rate_limited` or `spend_cap`, `400` for a malformed request, and `502` when Claude fails. `contract/summary.example.json` is the shared fixture. The proxy's schema describes it, and a Dart test parses it through `IntakeSummaryDto.fromJson(...).toDomain()`.

## Testing

| What | How |
|---|---|
| Every Bloc | `bloc_test` with fake repositories from `test/helpers/` |
| `RedFlagDetector` | Table test over all 21 lines of `bench/references.json` in both languages: lines 20 and 21 escalate, and lines 1–19 don't |
| Streams | `ChatChunk.failed` ends the reply and `ReplyRetryRequested` recovers it; an engine error never escapes `SpeechEngine` |
| SSE parsing | `ProxyChatRepository` against fixture event strings, including a split chunk and an `error` event |
| Contract | `contract/summary.example.json` parses into `IntakeSummary` |
| Approval gate | Widget test: the next step stays locked until `ApproveRequested` succeeds |
| Demo mode | Widget test: a full intake with no keys, from first message to an approved next step |
| Routes | Every route class round-trips: `CaseRoute(caseId: 'c_1').location` parses back to the same route, `/bench?line=abc` falls back to line 1, and an unknown path shows the error page |
| Accessibility | Tap-target, label and contrast guidelines pass on every screen, light and dark, EN and ES |
| Boundaries | `tool/check_boundaries.sh` prints nothing |

Run before each commit: `flutter analyze`, `dart format`, `flutter test`, `tool/check_boundaries.sh`, and `tsc --noEmit` in `intake/proxy/`.

## Why this shape

- **Feature-first scales with the team.** Each feature is a folder that one person can own, review and delete. Two people building two features rarely touch the same files, and a new engineer learns the app one folder at a time. The boundary script enforces the structure in CI, so it doesn't rely on review.
- **Typed routes make navigation a compile-time contract.** Renaming a parameter or changing its type breaks the build at every call site, not at runtime on a user's phone. The route tree in `routes.dart` doubles as the deep-link spec for a mobile build.
- **Two roles, one app, walled-off sides.** One store listing, build and sign-in keep a small team fast. The sides never import each other, so neither role's code leaks into the other's, and the boundary script enforces that. The role is enforced on the server and mirrored by the router.
- **One folder owns the look.** Screens use app components and semantic tokens from `shared/ui/`, never the kit or raw colors. A rebrand, a dark mode, a high-contrast mode or a kit upgrade changes `shared/ui/` and nothing else. The kit's pre-1.0 churn is the cost, contained by pinning the version and upgrading in commits of their own.
- **Named events form an audit trail.** Every change to an intake is an event like `UtteranceSubmitted` or `ApproveRequested`. A `BlocObserver` logs event types in debug builds, never their text. In a real product the same hook would feed an audit log, which clinical software needs anyway.
- **Each concern stays legible.** One Bloc per concern, with coordination only on the page or through a repository stream, gives a reviewer one place to read for each question.
- **The compiler catches what reviews used to catch.** Sealed states cover missed cases and make stale fields impossible, generated equality covers dropped emits, and `@useResult` covers discarded results.
- **The cost is accepted.** Bloc needs more files than Riverpod, and freezed and go_router_builder add a codegen step. Committing generated files keeps a clone runnable without that step. Feature-first can duplicate small helpers at first, which is cheaper than an early shared folder that every feature ends up depending on.

## Changing the engine

`SpeechEngine` is the seam for production:

```dart
abstract interface class SpeechEngine {
  Stream<SpeechResult> listen({required String localeId});
  Future<void> stop();
}
```

Tonight's implementation is `WebSpeechEngine`. Chrome's default recognition sends audio to Google, so this demo is not for real patient data. A production engine is either a cloud service with a BAA (the bench starts with AssemblyAI) or on-device recognition. Only `data/` and `bootstrap.dart` change. The Blocs, screens, and tests stay as they are.

## Out of scope

Accounts and sign-in, persistence beyond the browser session, real patient data, EHR integration, and native mobile builds. The structure leaves room for each, but none is built. Sign-in, for example, would be a new `shared/features/session` folder (the role, the employer, admin invitations) plus the role `redirect` on the router, with no change to the existing features.
