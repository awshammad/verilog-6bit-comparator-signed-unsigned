# 6‑Bit Signed/Unsigned Comparator (Structural + Behavioral) — Verilog

## Overview
This project implements a **6-bit comparator** that can operate in **unsigned** or **signed (two’s complement)** mode based on a select input `S`.

The design includes:
- A **structural (gate-level) implementation** built from basic gates (with delays).
- A **behavioral implementation** based on subtraction/comparison.
- An **exhaustive testbench** that checks **all 64×64 input combinations** for both modes and flags any mismatch.

This project was developed for **ADVANCED DIGITAL SYSTEMS DESIGN (ENCS3310)**.

---

## What the Comparator Does
Inputs:
- `A[5:0]`, `B[5:0]` — 6-bit values
- `clk` — clock (inputs are registered on the rising edge)
- `S` — mode select:
  - `S = 0` → **unsigned comparison**
  - `S = 1` → **signed comparison** (two’s complement)

Outputs:
- `Equal`   → 1 if `A == B`
- `Greater` → 1 if `A  > B`
- `Smaller` → 1 if `A  < B`

---

## Design Highlights

### Structural Comparator (`comparator6bits_struct`)
- Registers inputs `A`, `B`, and `S` on `posedge clk` (synchronous design).
- Builds a 6-bit compare by cascading **2-bit comparators** across:
  - bits `[5:4]`, `[3:2]`, `[1:0]`
- For **signed mode**, it detects when the MSBs differ and selects the correct result using multiplexers.

### Behavioral Comparator (`comparator6bits_behav`)
- Computes both signed and unsigned subtraction results.
- Uses the subtraction sign/zero to derive `Equal/Greater/Smaller` depending on `S`.

### Testbench (`TB`)
- Generates a clock signal and exhaustively tests:
  - all values of `A = 0..63`
  - all values of `B = 0..63`
  - both modes (`S=0` and `S=1`)
- Compares structural vs behavioral outputs; prints **Pass/Fail** information.
- Stops the simulation at the end.

---

## Files
- `compare.v` — contains:
  - `comparator6bits_struct`
  - `comparator6bits_behav`
  - `comparator2bits`
  - `mux2x1`
  - `TB` (testbench)
- `1221697.pdf` — project report/documentation

---

## How to Run (Simulation)

### Option 1: Icarus Verilog (recommended if you want quick CLI testing)
1. Install Icarus Verilog
2. Run:
```bash
iverilog -g2012 compare.v -o sim.out
vvp sim.out
```

### Option 2: ModelSim / Questa / Vivado Simulator
1. Create a new project
2. Add `compare.v`
3. Set `TB` as the top module
4. Run simulation and view console output / waveforms

---

## Notes
- This project includes **gate delays** in the structural modules (e.g., `not #2`, `and #6`, `xnor #8`, etc.) to help evaluate timing/latency.
- If you upload this repo to GitHub, it’s fine to include the PDF report, but you can also place it under a `docs/` folder for cleanliness.

---

## Author
- Aws Hammad (1221697)
