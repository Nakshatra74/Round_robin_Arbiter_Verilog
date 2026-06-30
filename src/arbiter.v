`timescale 1ns / 1ps

module arbiter(

    input  wire CLK,
    input  wire RST_I,
    input  wire CYC3,
    input  wire CYC2,
    input  wire CYC1,
    input  wire CYC0,

    output wire GNT3,
    output wire GNT2,
    output wire GNT1,
    output wire GNT0,
    output wire COMCYC,
    output wire [1:0] GNT
);

// Internal Registers   to remember who currently uses the resource
reg lgnt0;
reg lgnt1;
reg lgnt2;
reg lgnt3;

reg LMAS1;  //these store the round robin pointer so that next search begins after that device
reg LMAS0;

// Next Grant Signals
reg next_gnt0;      //these are temporary values to tackle timing problems which holds the next grant untilthe clock edge then they move to lgnt
reg next_gnt1;      
reg next_gnt2;
reg next_gnt3;

// Encoder
wire [1:0] enc_gnt;

// COMCYC   
wire lcomcyc;       //to check if the bus is still occupied

assign lcomcyc =
       (CYC0 & lgnt0)
    |  (CYC1 & lgnt1)
    |  (CYC2 & lgnt2)
    |  (CYC3 & lgnt3);

// FSM

localparam IDLE      = 2'b00;
localparam ARBITRATE = 2'b01;
localparam HOLD      = 2'b10;

reg [1:0] state;
reg [1:0] next_state;      //where should the bus go next

// FSM Register

always @(posedge CLK)
begin

    if(RST_I)
        state <= IDLE;
    else
        state <= next_state;

end

// FSM Next State Logic

always @(*)
begin
    case(state)

       IDLE:
        begin
            if(CYC0 || CYC1 || CYC2 || CYC3)
                next_state = ARBITRATE;
            else
                next_state = IDLE;
        end
 
        ARBITRATE:
        begin
            next_state = HOLD;
        end

        HOLD:
        begin
            if(lcomcyc)
                next_state = HOLD;
            else
                next_state = IDLE;
        end

        default:
            next_state = IDLE;

    endcase
end

// Combinational Arbitration Logic

always @(*)
begin
    // Default: no grants
    next_gnt0 = 1'b0;
    next_gnt1 = 1'b0;
    next_gnt2 = 1'b0;
    next_gnt3 = 1'b0;

    // Only choose a winner during the ARBITRATE state
    if(state == ARBITRATE)
    begin
        next_gnt0 =
              (~LMAS1 & ~LMAS0 & ~CYC3 & ~CYC2 & ~CYC1 &  CYC0)
            | (~LMAS1 &  LMAS0 & ~CYC3 & ~CYC2 &  CYC0)
            | ( LMAS1 & ~LMAS0 & ~CYC3 &  CYC0)
            | ( LMAS1 &  LMAS0 &  CYC0);

        next_gnt1 =
              (~LMAS1 & ~LMAS0 &  CYC1)
            | (~LMAS1 &  LMAS0 & ~CYC3 & ~CYC2 &  CYC1 & ~CYC0)
            | ( LMAS1 & ~LMAS0 & ~CYC3 &  CYC1 & ~CYC0)
            | ( LMAS1 &  LMAS0 &  CYC1 & ~CYC0);

        next_gnt2 =
              (~LMAS1 & ~LMAS0 &  CYC2 & ~CYC1)
            | (~LMAS1 &  LMAS0 &  CYC2)
            | ( LMAS1 & ~LMAS0 & ~CYC3 &  CYC2 & ~CYC1 & ~CYC0)
            | ( LMAS1 &  LMAS0 &  CYC2 & ~CYC1 & ~CYC0);

        next_gnt3 =
              (~LMAS1 & ~LMAS0 &  CYC3 & ~CYC2 & ~CYC1)
            | (~LMAS1 &  LMAS0 &  CYC3 & ~CYC2)
            | ( LMAS1 & ~LMAS0 &  CYC3)
            | ( LMAS1 &  LMAS0 &  CYC3 & ~CYC2 & ~CYC1 & ~CYC0);
    end

    // During HOLD, keep the current grant
    else if(state == HOLD)
    begin
        next_gnt0 = lgnt0;
        next_gnt1 = lgnt1;
        next_gnt2 = lgnt2;
        next_gnt3 = lgnt3;
    end
end

// Encoder      //to reduce hardware from 4 to 2 wires

assign enc_gnt[1] = next_gnt3 | next_gnt2;
assign enc_gnt[0] = next_gnt3 | next_gnt1;

// Grant Register

always @(posedge CLK)
begin
    if(RST_I)
    begin
        lgnt0 <= 1'b0;
        lgnt1 <= 1'b0;
        lgnt2 <= 1'b0;
        lgnt3 <= 1'b0;

        LMAS0 <= 1'b0;
        LMAS1 <= 1'b0;
    end

    else
    begin
        case(state)

        // Load a new winner
        ARBITRATE:
        begin
            lgnt0 <= next_gnt0;
            lgnt1 <= next_gnt1;
            lgnt2 <= next_gnt2;
            lgnt3 <= next_gnt3;
            // Update the rotating pointer
            LMAS0 <= enc_gnt[0];
            LMAS1 <= enc_gnt[1];
        end

        // Hold current winner while it is requesting

        HOLD:
        begin
            lgnt0 <= next_gnt0;
            lgnt1 <= next_gnt1;
            lgnt2 <= next_gnt2;
            lgnt3 <= next_gnt3;
        end

        // Bus released

        IDLE:
        begin
            lgnt0 <= 1'b0;
            lgnt1 <= 1'b0;
            lgnt2 <= 1'b0;
            lgnt3 <= 1'b0;
        end
        endcase
    end

end

// Outputs

assign GNT0 = lgnt0;
assign GNT1 = lgnt1;
assign GNT2 = lgnt2;
assign GNT3 = lgnt3;

assign COMCYC = lcomcyc;

assign GNT = enc_gnt;

endmodule
