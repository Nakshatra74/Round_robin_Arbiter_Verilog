# Round Robin Arbiter (Verilog)

## Overview
This project implements a 4-requester synchronous Round Robin Arbiter in Verilog. The arbiter provides fair access to a shared bus by rotating the priority after each completed transaction. The design uses a Finite State Machine (FSM) with three states: IDLE, ARBITRATE, and HOLD.

## Features
- 4-requester round robin arbitration
- FSM-based control logic
- Fair rotating priority
- One grant active at a time
- Bus busy detection using COMCYC
- Tested using Vivado Simulator

## Project Structure

```
src/
    arbiter.v

tb/
    arbiter_tb.v

docs/

README.md
```

## Inputs

| Signal | Description |
|---------|-------------|
| CLK | System clock |
| RST_I | Active-high reset |
| CYC0-CYC3 | Request signals |

## Outputs

| Signal | Description |
|---------|-------------|
| GNT0-GNT3 | Grant signals |
| COMCYC | Bus busy indication |
| GNT[1:0] | Encoded grant output |

## FSM

The arbiter operates using three states:

- **IDLE** – Waits for incoming requests.
- **ARBITRATE** – Selects the next requester according to the round-robin priority.
- **HOLD** – Maintains the current grant until the requester releases the bus.

## How to Simulate

1. Open the project in Vivado.
2. Add `src/arbiter.v` as a design source.
3. Add `tb/arbiter_tb.v` as a simulation source.
4. Run **Behavioral Simulation**.
5. Observe the request and grant signals in the waveform window.

## Test Cases

The testbench verifies:
- Reset operation
- Single requester
- Multiple simultaneous requesters
- Grant hold while request remains active
- Round-robin priority rotation
- All requesters active simultaneously

## Author

Nakshatra Goyal
