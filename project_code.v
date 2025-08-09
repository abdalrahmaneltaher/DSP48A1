// Mux_with_dff
module Mux_with_dff(clk,en,rst,d,out);
parameter opmode = 1, RSTYPE = "SYNC",size = 18;
input clk,en,rst;
input [size-1:0] d ;
output reg [size-1:0]out;
generate
    if(opmode)begin
        if(RSTYPE ==  "SYNC") begin
            always @(posedge clk) begin
                if(rst)
                    out<=0;
                else begin
                    if(en)
                        out<=d;
                end
            end
        end
        else begin
            always @(posedge clk or posedge rst) begin
                if(rst)
                    out<=0;
                else begin
                    if(en)
                        out<=d;
                end  
            end
        end
    end
    else begin
        always @(*) begin
            out = d ;    
        end
    end
endgenerate
endmodule 
// DSP48A1
module DSP48A1(A,B,C,D,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
//parameter. 
parameter A0REG = 0,A1REG=1,B0REG=0,B1REG=1,CREG=1,DREG=1,MREG=1,PREG=1,CARRYINREG=1,CARRYOUTREG=1,OPMODEREG = 1,CARRYINSEL="OPMODE5",B_INPUT="DIRECT",RSTTYPE="SYNC";
//input.
input [17:0]A,B,D,BCIN;
input [47:0] PCIN,C;
input [7:0]OPMODE;
input CLK,CARRYIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
//output
output [47:0] PCOUT,P;
output [17:0]BCOUT;
output [35:0] M ;
output CARRYOUT,CARRYOUTF;
//wire.
wire CYI_in,CYI_out,CYO_in;
wire [17:0]B_INPUT_WIRE,D_out,B0_out,A0_out,B1_in,B1_out,A1_out,Pre_Adder_Subtracter;
wire[47:0] post_Adder_Subtracter,C_out,concat,out_z,out_x,multipler_out_48;
wire [7:0]OPMODE_out;
wire [35:0]  multipler_in,multipler_out;
// B or BCIN or 0
assign B_INPUT_WIRE=(B_INPUT == "DIRECT")?B:(B_INPUT == "CASCADE")?BCIN:0;
//DREG ,B0_out,A0REG and CREG 
Mux_with_dff #(.opmode(B0REG),.size(18),.RSTYPE(RSTTYPE))b0reg(.clk(CLK),.en(CEB),.rst(RSTB),.d(B_INPUT_WIRE),.out(B0_out));
Mux_with_dff #(.opmode(A0REG),.size(18),.RSTYPE(RSTTYPE))a0reg(.clk(CLK),.en(CEA),.rst(RSTA),.d(A),.out(A0_out));
Mux_with_dff #(.opmode(DREG),.size(18),.RSTYPE(RSTTYPE))dreg(.clk(CLK),.en(CED),.rst(RSTD),.d(D),.out(D_out));
Mux_with_dff #(.opmode(CREG),.size(48),.RSTYPE(RSTTYPE))creg(.clk(CLK),.en(CEC),.rst(RSTC),.d(C),.out(C_out));
// Pre_Adder_Subtracter
Mux_with_dff #(.opmode(OPMODEREG),.size(1),.RSTYPE(RSTTYPE))opmode6(.clk(CLK),.en(CEOPMODE),.rst(RSTOPMODE),.d(OPMODE[6]),.out(OPMODE_out[6]));
assign Pre_Adder_Subtracter =(OPMODE_out[6] == 1)? (D_out-B0_out):(D_out+B0_out);
// select Pre_Adder_Subtracter or B0_out
Mux_with_dff #(.opmode(OPMODEREG),.size(1),.RSTYPE(RSTTYPE))opmode4(.clk(CLK),.en(CEOPMODE),.rst(RSTOPMODE),.d(OPMODE[4]),.out(OPMODE_out[4]));
assign B1_in = (OPMODE_out[4]== 1)? Pre_Adder_Subtracter:B0_out;
// A1REG and B1REG
Mux_with_dff #(.opmode(B1REG),.size(18),.RSTYPE(RSTTYPE))b1reg(.clk(CLK),.en(CEB),.rst(RSTB),.d(B1_in),.out(B1_out));
Mux_with_dff #(.opmode(A1REG),.size(18),.RSTYPE(RSTTYPE))a1reg(.clk(CLK),.en(CEA),.rst(RSTA),.d(A0_out),.out(A1_out));
// multipler operation.
assign BCOUT=B1_out;
assign multipler_in = B1_out*A1_out;
//MREG
Mux_with_dff #(.opmode(MREG),.size(36),.RSTYPE(RSTTYPE))mreg(.clk(CLK),.en(CEM),.rst(RSTM),.d(multipler_in),.out(multipler_out));
//buffer M
assign M = ~(~multipler_out);
//(multipler_out_48) is 48 bit
assign multipler_out_48=multipler_out;
// concatination.
assign concat ={D_out[11:0],A1_out,B1_out};
//Mux_4_x
Mux_with_dff #(.opmode(OPMODEREG),.size(2),.RSTYPE(RSTTYPE))opcode10(.clk(CLK),.en(CEOPMODE),.rst(RSTOPMODE),.d(OPMODE[1:0]),.out(OPMODE_out[1:0]));
assign out_x =(OPMODE_out[1:0] == 2'b00)? 48'd0:(OPMODE_out[1:0] == 2'b01)? multipler_out_48:(OPMODE_out[1:0] == 2'b10)? P: concat ; 
// Mux_4_z
Mux_with_dff #(.opmode(OPMODEREG),.size(2),.RSTYPE(RSTTYPE))opcode32(.clk(CLK),.en(CEOPMODE),.rst(RSTOPMODE),.d(OPMODE[3:2]),.out(OPMODE_out[3:2]));
assign out_z =(OPMODE_out[3:2] == 2'b00)? 48'd0:(OPMODE_out[3:2] == 2'b01)? PCIN:(OPMODE_out[3:2] == 2'b10)? P: C_out ; 
// select OPMODE_out[5] or CARRYIN or 0 . 
Mux_with_dff #(.opmode(OPMODEREG),.size(1),.RSTYPE(RSTTYPE))opmode5(.clk(CLK),.en(CEOPMODE),.rst(RSTOPMODE),.d(OPMODE[5]),.out(OPMODE_out[5]));
assign CYI_in=(CARRYINSEL == "OPMODE5")?OPMODE_out[5]:(CARRYINSEL == "CARRYIN")?CARRYIN:0;
//CYI. 
Mux_with_dff #(.opmode(CARRYINREG),.size(1),.RSTYPE(RSTTYPE))cyireg(.clk(CLK),.en(CECARRYIN),.rst(RSTCARRYIN),.d(CYI_in),.out(CYI_out));
// post_Adder_Subtracter
Mux_with_dff #(.opmode(OPMODEREG),.size(1),.RSTYPE(RSTTYPE))opmode7(.clk(CLK),.en(CEOPMODE),.rst(RSTOPMODE),.d(OPMODE[7]),.out(OPMODE_out[7]));
assign {CYO_in,post_Adder_Subtracter} = (OPMODE_out[7] == 1)? (out_z-(out_x+CYI_out)):(out_z+out_x+CYI_out);
// PREG
Mux_with_dff #(.opmode(PREG),.size(48),.RSTYPE(RSTTYPE))preg(.clk(CLK),.en(CEP),.rst(RSTP),.d(post_Adder_Subtracter),.out(P));
assign PCOUT = P;
// CYO
Mux_with_dff #(.opmode(CARRYOUTREG),.size(1),.RSTYPE(RSTTYPE))cyoreg(.clk(CLK),.en(CECARRYIN),.rst(RSTCARRYIN),.d(CYO_in),.out(CARRYOUT));
assign CARRYOUTF =CARRYOUT;
endmodule
