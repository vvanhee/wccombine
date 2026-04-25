# WCCombine

A minimal iOS calculator for combining workers' compensation impairment ratings using the standard whole-person efficiency formula.

---

## What it does

WCCombine lets you enter a series of impairment percentages (1–99%) and instantly see the correctly combined whole-person impairment. Tap in each rating on the numpad, press **+** to add it to the set, and the result updates in real time. Tap any pill to remove it.

---

## The formula

$$C = 1 - \prod_{i=1}^{n}(1 - A_i)$$

where each $A_i$ is an impairment expressed as a decimal fraction.

In the two-rating case this expands to:

$$C = A + B(1 - A) = A + B - AB$$

**Why not just add?** Each subsequent impairment can only consume what earlier impairments left intact. A 60% impairment leaves 40% of whole-person capacity remaining; a further 30% impairment removes 30% of *that* remainder (12 percentage points), not 30% of the original whole. The total is therefore 72%, not 90%. Because every factor $(1 - A_i)$ lies in $[0, 1]$, the product is bounded below by zero and combined impairment is bounded above by 100%—no combination of finite impairments can overflow.

The operation is commutative and associative, so entry order does not matter.

---

## Historical background

### Origin: WWI-era actuarial convention

The formula did not originate in medicine. The War Risk Insurance Act Amendments of 1917 directed the Bureau of War Risk Insurance to schedule reductions in earning capacity from *combinations* of injuries. The first official Veterans Bureau schedule (1921), refined in 1925 and 1945, encoded the efficiency-reduction approach that still appears verbatim in federal regulation today.

### Codification in federal law: 38 CFR § 4.25

The VA's Combined Ratings Table is the clearest statutory articulation of the concept:

> *"A person having a 60 percent disability is considered 40 percent efficient. Proceeding from this 40 percent efficiency, the effect of a further 30 percent disability is to leave only 70 percent of the efficiency remaining after consideration of the first disability, or 28 percent efficiency altogether. The individual is thus 72 percent disabled."*

The VA rounds only once, at the end, to the nearest 10% (with 5% always rounding up). It also applies a bilateral factor (38 CFR § 4.26): when both paired limbs or muscles are impaired, 10% of the combined bilateral value is *added* (not combined) before further combination—a regulatory recognition that bilateral impairment is functionally worse than the mechanical sum of two unilateral ones.

### Migration into medicine: 1958 JAMA → AMA Guides (1971–present)

The AMA Board of Trustees formed a Committee on Medical Rating of Physical Impairment in 1956. Its first guide appeared in *JAMA* in 1958 and was compiled into the **AMA Guides First Edition** in 1971. The formula's lineage runs:

**VA Schedule (1921) → 1945 VASRD → 1958 JAMA Guide → AMA Guides 1st Ed. (1971)**

The **Combined Values Chart (CVC)**—the tabulated form of $A + B(1-A)$—has appeared in every numbered AMA Guides edition from the Second (1984) through the current Sixth (2008) and its updates. The formula itself has never changed across editions; what changed is the upstream methodology (DRE → DBI grids, etc.) that generates the individual $A_i$ values fed into it.

The AMA Guides are explicit that the convention is not empirically derived:

> *"A scientific formula has not been established to indicate the best way to combine multiple impairments."* (5th Ed., Ch. 1.4)

### Minnesota's statutory codification

Minnesota is one of the few states to explicitly codify $A + B(1-A)$ in statute (**Minn. Stat. § 176.105**; **Minn. R. 5223.0300, subp. 3(E)**) while using its own impairment schedule rather than the AMA Guides. The Minnesota, AMA, and VA formulas are mathematically identical; differences across jurisdictions are in rounding conventions, bilateral surcharges, and the upstream rating methodology—not in the algebra.

---

## Jurisdiction map

| Combination method | Representative jurisdictions |
|---|---|
| AMA CVC via Guides 6th Ed. | AK, AZ, CT, DC, IN, LA, MA, MS, MT, NM, OK, PA (IRE), RI, SD, TN, WY; FECA, LHWCA, DBA |
| AMA CVC via Guides 5th Ed. | CA (PDRS §8), DE, GA, HI, IA, KY, NV, NH, ND, OH, VT; EEOICPA Part E |
| AMA CVC via Guides 4th Ed. | AL, AR, KS, ME, MD, TX, WV |
| Own schedule, formula codified as A + B(1-A) | **Minnesota** |
| Own schedule with embedded CVC lookup | Florida (1996 UPIRS §15) |
| Schedule Loss of Use, no combination | New York (WCL §15(3)); Illinois |
| Category system, no percentage formula | Washington (WAC 296-20-220) |
| Wage-earning capacity, no impairment formula | Michigan, New Jersey, Nebraska, Missouri, Virginia |

---

## Worked examples (Minnesota/AMA rounding)

| Ratings | Combined | Notes |
|---|---|---|
| 60%, 30% | **72%** | 0.60 + 0.30 − 0.18 = 0.72 |
| 22%, 10% | **30%** | 0.22 + 0.10 − 0.022 = 0.298 → 30% |
| 50%, 30%, 10% | **69%** | 50+30→65; 65+10→68.5 → 69% |

The VA produces the same intermediate results but rounds once at the end to the nearest 10%, so the three-rating example becomes **70%**.

---

## Key critiques

- **Always employer-favorable:** $A + B(1-A) < A + B$ whenever both are positive, so the formula systematically reduces recovery relative to simple addition. (Pryor, *Harvard Law Review*, 1990)
- **Same-function problem:** When two impairments attack the same activity of daily living, multiplicative combination can *understate* disability. California's *Athens Administrators v. WCAB (Kite)* (2013) and *Vigil v. County of Kern* (WCAB en banc, 2021) allow case-specific rebuttal on this basis. Minnesota's statutory formula is not judicially rebuttable in the same way.
- **No empirical grounding:** Peer-reviewed comparisons (Spieler et al., *JAMA* 2000; Forst et al., *JOEM* 2010) find no validated correspondence between combined impairment percentages and actual functional disability or earning loss.

---

## Tech stack

- Swift / SwiftUI
- iOS 17+
- No dependencies

---

## License

MIT
