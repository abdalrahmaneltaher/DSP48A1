module DSP48A1_tb();
//input
reg [17:0]A,B,D,BCIN;
reg [47:0] PCIN,C;
reg [7:0]OPMODE;
reg CLK,CARRYIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
//out dut 
wire [47:0] PCOUT_dut,P_dut;
wire [17:0]BCOUT_dut;
wire [35:0] M_dut ;
wire CARRYOUT_dut,CARRYOUTF_dut;
//output expect
reg [47:0] PCOUT_expect,P_expect;
reg [17:0]BCOUT_expect;
reg [35:0] M_expect ;
reg CARRYOUT_expect,CARRYOUTF_expect;
// instantiation
DSP48A1 dut(A,B,C,D,CLK,CARRYIN,
              OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,
              CEOPMODE,PCIN,BCOUT_dut,PCOUT_dut,P_dut,M_dut,CARRYOUT_dut,CARRYOUTF_dut);
initial begin
    CLK = 0;
    forever
        #1 CLK = ~ CLK ;  
end
initial begin
    //verify reset operation.
    RSTA=1;RSTB=1;RSTM=1;RSTP=1;RSTC=1;RSTD=1;RSTCARRYIN=1;RSTOPMODE=1;CEA=1;CEB=1;CEM=1;CEP=1;CEC=1;CED=1;CECARRYIN=1;CEOPMODE=1;
    A = $random;B= $random;D= $random;BCIN= $random;PCIN= $random;C= $random;OPMODE= $random;CARRYIN= $random;
    @(negedge CLK);
     PCOUT_expect=0;P_expect=0;BCOUT_expect=0;CARRYOUT_expect=0;CARRYOUTF_expect=0; M_expect =0;
    if(PCOUT_dut !=PCOUT_expect || P_dut !=P_expect || BCOUT_dut !=BCOUT_expect || M_dut !=M_expect || CARRYOUT_dut != CARRYOUT_expect || CARRYOUTF_dut != CARRYOUTF_expect)begin
        $display("error : P_dut=%h,P_expect =%h  ",P_dut,P_expect);
        $stop;
    end
    RSTA=0;RSTB=0;RSTM=0;RSTP=0;RSTC=0;RSTD=0;RSTCARRYIN=0;RSTOPMODE=0;CEA=1;CEB=1;CEM=1;CEP=1;CEC=1;CED=1;CECARRYIN=1;CEOPMODE=1;
    //verify dsp path 1 .
    OPMODE = 8'b11011101;
    A = 20;B=10;C=350;D=25;
    BCIN =$random;PCIN=$random;CARRYIN=$random;
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
      BCOUT_expect = 'hf ;M_expect='h12c;P_expect='h32;PCOUT_expect='h32;CARRYOUT_expect=0;CARRYOUTF_expect=0;
    if(PCOUT_dut !=PCOUT_expect || P_dut !=P_expect || BCOUT_dut !=BCOUT_expect || M_dut !=M_expect || CARRYOUT_dut != CARRYOUT_expect || CARRYOUTF_dut != CARRYOUTF_expect)begin
        $display("error : P_dut=%h,P_expect =%h  ",P_dut,P_expect);
        $stop;
    end
    //verify dsp path 2 .
    OPMODE =8'b00010000;
    A = 20;B=10;C=350;D=25;
    BCIN =$random;PCIN=$random;CARRYIN=$random;
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    BCOUT_expect = 'h23; M_expect = 'h2bc; P_expect =0; PCOUT_expect =0;CARRYOUT_expect = 0; CARRYOUTF_expect = 0;
    if(PCOUT_dut !=PCOUT_expect || P_dut !=P_expect || BCOUT_dut !=BCOUT_expect || M_dut !=M_expect || CARRYOUT_dut != CARRYOUT_expect || CARRYOUTF_dut != CARRYOUTF_expect)begin
        $display("error : P_dut=%h,P_expect =%h  ",P_dut,P_expect);
        $stop;
    end
    // verify dsp path 3.
    OPMODE = 8'b00001010;
    A = 20;B=10;C=350;D=25;
    BCIN =$random;PCIN=$random;CARRYIN=$random;
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    BCOUT_expect = 'ha; M_expect = 'hc8;
    if(PCOUT_dut !=PCOUT_expect || P_dut !=P_expect || BCOUT_dut !=BCOUT_expect || M_dut !=M_expect || CARRYOUT_dut != CARRYOUT_expect || CARRYOUTF_dut != CARRYOUTF_expect)begin
        $display("error : P_dut=%h,P_expect =%h  ",P_dut,P_expect);
        $stop;
    end
    // verify dsp path 4.
     OPMODE = 8'b10100111;
    A = 5; B = 6; C = 350; D = 25; PCIN = 3000;BCIN =$random;CARRYIN=$random;
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    BCOUT_expect = 'h6; M_expect = 'h1e;P_expect = 'hfe6fffec0bb1;PCOUT_expect = 'hfe6fffec0bb1; CARRYOUT_expect = 1;CARRYOUTF_expect = 1;
    @(negedge CLK);
    if(PCOUT_dut !=PCOUT_expect || P_dut !=P_expect || BCOUT_dut !=BCOUT_expect || M_dut !=M_expect || CARRYOUT_dut != CARRYOUT_expect || CARRYOUTF_dut != CARRYOUTF_expect)begin
        $display("error : P_dut=%h,P_expect =%h  ",P_dut,P_expect);
        $stop;
    end
    //stop
    $stop;
end
endmodule
