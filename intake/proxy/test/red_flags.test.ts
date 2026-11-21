import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { detectRedFlag } from "../lib/red_flags.js";

type Line = { n: number; en: { text: string }; es: { text: string }; expect_red_flag: boolean };
const refs = JSON.parse(readFileSync(new URL("../../../bench/references.json", import.meta.url), "utf8")) as { lines: Line[] };

describe("detectRedFlag over the bench script", () => {
  for (const line of refs.lines) {
    for (const lang of ["en", "es"] as const) {
      it(`line ${line.n} ${lang} ${line.expect_red_flag ? "escalates" : "does not escalate"}`, () => {
        expect(detectRedFlag(line[lang].text) !== null).toBe(line.expect_red_flag);
      });
    }
  }

  it("tells crisis from emergency", () => {
    expect(detectRedFlag("I have chest pain")).toBe("emergency");
    expect(detectRedFlag("I don't want to be here anymore")).toBe("crisis");
    expect(detectRedFlag("Ya no quiero vivir")).toBe("crisis");
    expect(detectRedFlag("Me quiero matar")).toBe("crisis");
  });

  it("catches common wordings", () => {
    for (const t of ["I have shortness of breath", "Tengo dolor de pecho", "I think it's a heart attack", "Creo que es un ataque al corazón", "Mi papá tuvo un infarto"]) {
      expect(detectRedFlag(t), t).toBe("emergency");
    }
  });
});
