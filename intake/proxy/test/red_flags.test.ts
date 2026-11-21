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

  it("a denial is not a red flag", () => {
    for (const t of ["I have no chest pain", "I don't have chest pain, just a cough", "Sin dolor de pecho", "No tengo dolor en el pecho", "I'm not short of breath"]) {
      expect(detectRedFlag(t), t).toBeNull();
    }
    expect(detectRedFlag("No chest pain, but I can't breathe")).toBe("emergency");
    expect(detectRedFlag("I have no fever and can't breathe")).toBe("emergency");
    expect(detectRedFlag("Sin embargo me duele el pecho")).toBe("emergency");
    expect(detectRedFlag("No tengo fiebre y me falta el aire")).toBe("emergency");
  });

  it("works without Spanish accents and with lay stroke words", () => {
    for (const t of ["Tengo confusion", "Siento presion en el pecho", "dolor en mi pecho", "no puedo mover mi brazo", "My face is drooping and I'm slurring", "numbness in my arm"]) {
      expect(detectRedFlag(t), t).toBe("emergency");
    }
    expect(detectRedFlag("no quiero estar aqui")).toBe("crisis");
  });

  it("talking about someone else's suicide is not a crisis; intent is", () => {
    expect(detectRedFlag("My sister died by suicide last year")).toBeNull();
    for (const t of ["I'm suicidal", "I've been thinking about suicide", "Pienso en suicidarme", "Tengo ideas suicidas"]) {
      expect(detectRedFlag(t), t).toBe("crisis");
    }
  });

  it("intent to cut, and \"she's confused\"", () => {
    for (const t of ["I want to cut myself", "I am going to cut myself"]) expect(detectRedFlag(t), t).toBe("crisis");
    for (const t of ["She's confused", "He's very confused"]) expect(detectRedFlag(t), t).toBe("emergency");
    expect(detectRedFlag("She's confused about the bill")).toBeNull();
  });

  it("haircuts and billing confusion are not red flags; Spanish ER trips are", () => {
    for (const t of ["Quiero cortarme el pelo", "Tengo mucha confusión con mi factura"]) expect(detectRedFlag(t), t).toBeNull();
    expect(detectRedFlag("Quiero cortarme")).toBe("crisis");
    for (const t of ["¿Debo llevar a mi mamá a urgencias?", "¿Tengo que ir a urgencias?"]) expect(detectRedFlag(t), t).toBe("emergency");
  });

  it("explicit suicide wording; spills and shaving cuts are not red flags", () => {
    for (const t of ["I have thoughts of suicide", "I attempted suicide last year", "Tuve un intento de suicidio", "Tengo ideación suicida", "pensamientos de suicidio"]) {
      expect(detectRedFlag(t), t).toBe("crisis");
    }
    for (const t of ["Me derramé el café", "I cut myself shaving"]) expect(detectRedFlag(t), t).toBeNull();
    expect(detectRedFlag("Creo que tuvo un derrame")).toBe("emergency");
    expect(detectRedFlag("derrame cerebral")).toBe("emergency");
  });

  it("confusion needs to be a symptom, and the ER a question about going", () => {
    for (const t of [
      "I'm confused about my bill",
      "I'm confused about how this works",
      "She is confused by the form",
      "Estoy confundida con mi factura",
      "I went to the emergency room last month, how do I get reimbursed?",
    ]) {
      expect(detectRedFlag(t), t).toBeNull();
    }
    for (const t of [
      "My dad has been confused since this morning",
      "She seems very confused and sleepy",
      "Mi mamá está muy confundida",
      "Should I take him to the ER?",
      "¿Lo llevo a urgencias?",
    ]) {
      expect(detectRedFlag(t), t).toBe("emergency");
    }
  });

  it("overdose is a crisis; an accidental injury is not", () => {
    for (const t of ["I took a whole bottle of pills", "I think I overdosed", "Me tomé todas las pastillas", "sobredosis"]) {
      expect(detectRedFlag(t), t).toBe("crisis");
    }
    expect(detectRedFlag("I hurt myself lifting boxes at work")).toBeNull();
    expect(detectRedFlag("I want to hurt myself")).toBe("crisis");
  });

  it("single stroke signs, chest pressure, and uncontracted crisis wording", () => {
    for (const t of ["I have chest pressure", "pain in chest", "my face is drooping", "facial droop", "my arm is numb"]) {
      expect(detectRedFlag(t), t).toBe("emergency");
    }
    for (const t of ["I do not want to live", "I do not want to be alive"]) expect(detectRedFlag(t), t).toBe("crisis");
  });

  it("catches common wordings", () => {
    for (const t of ["I have shortness of breath", "Tengo dolor de pecho", "I think it's a heart attack", "Creo que es un ataque al corazón", "Mi papá tuvo un infarto"]) {
      expect(detectRedFlag(t), t).toBe("emergency");
    }
  });
});
