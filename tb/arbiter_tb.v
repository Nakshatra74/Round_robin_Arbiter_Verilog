`timescale 1ns/1ps

module arbiter_tb;

    reg CLK;
    reg RST_I;
    reg CYC3;
    reg CYC2;
    reg CYC1;
    reg CYC0;
    
    // Outputs
    wire GNT3;
    wire GNT2;
    wire GNT1;
    wire GNT0;
    wire COMCYC;
    wire [1:0] GNT;

    // Instantiate DUT
    arbiter DUT(.CLK(CLK),.RST_I(RST_I),.CYC3(CYC3),.CYC2(CYC2),.CYC1(CYC1),.CYC0(CYC0),
    .GNT3(GNT3),.GNT2(GNT2),.GNT1(GNT1),.GNT0(GNT0),.COMCYC(COMCYC),.GNT(GNT)
    );

    // Clock Generation
    initial
    begin
        CLK = 0;
        forever #5 CLK = ~CLK;      //10ns clock period
    end
    
    // Monitor

    initial
    begin
        $display("------------------------------------------------------------");
        $display("Time  Req   Grant  Mask  COMCYC");
        $display("------------------------------------------------------------");

        $monitor("%4t   %b%b%b%b    %b%b%b%b    %b     %b",
                $time,
                CYC3,CYC2,CYC1,CYC0,
                GNT3,GNT2,GNT1,GNT0,
                GNT,
                COMCYC);
    end
    
    // Test Sequence

    initial
    begin
        // Reset
        RST_I = 1;
        CYC0 = 0;
        CYC1 = 0;
        CYC2 = 0;
        CYC3 = 0;
        #20;
        RST_I = 0;

        // TEST 1 : Device0 requests

        $display("\nTEST1 : Device0 Request");

        CYC0 = 1;
        #40;
        CYC0 = 0;

        #20;
        // TEST2 : Device1 requests

        $display("\nTEST2 : Device1 Request");

        CYC1 = 1;

        #40;

        CYC1 = 0;

        #20;
        // TEST3 : Device2 and Device3 together
        $display("\nTEST3 : Device2 and Device3");

        CYC2 = 1;
        CYC3 = 1;

        #50;

        CYC2 = 0;

        #30;

        CYC3 = 0;

        #20;

        // TEST4 : All request simultaneously

        $display("\nTEST4 : All Devices");

        CYC0 = 1;
        CYC1 = 1;
        CYC2 = 1;
        CYC3 = 1;

        #60;
        // Release winner

        if(GNT0)
            CYC0 = 0;

        if(GNT1)
            CYC1 = 0;

        if(GNT2)
            CYC2 = 0;

        if(GNT3)
            CYC3 = 0;
        #40;
        // Remaining requests continue
         #60;
        // Release everyone
         CYC0 = 0;
        CYC1 = 0;
        CYC2 = 0;
        CYC3 = 0;

        #40;

        // TEST5 : Round Robin Check

        $display("\nTEST5 : Round Robin Rotation");
        //Device0
        CYC0 = 1;
        #40;
        CYC0 = 0;
        #20;
        //Device1
        CYC1 = 1;
        #40;
        CYC1 = 0;
        #20;
        //Device2
        CYC2 = 1;
        #40;
        CYC2 = 0;
        #20;

        //Device3
        CYC3 = 1;
        #40;
        CYC3 = 0;
        #20;

        $display("\nSimulation Finished");
        #20;
        $finish;

    end

endmodule
