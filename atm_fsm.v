`timescale 1ns / 1ps
`define Welcome_screen 3'b000
`define Processing 3'b001
`define Enter 3'b010
`define Select 3'b011
`define Success_and_newtransaction 3'b101
`define Error 3'b111
`define hold 1'b0
`define release 1'b1

module atm_fsm(input clk,reset, card_in, pin_check,withdraw1_or_balanceenq0,currentbalance1_ministatement0,amount,
               transaction_success,balance_enquiry_success,new_transaction ,
               output reg card_eject,cash_out,receipt_out, output reg [2:0] display);

parameter IDLE = 4'd0,
CARD_INSERTED =4'd1,
ENTER_PIN = 4'd2,
VERIFY_PIN = 4'd3,
MENU = 4'd4,
    ENTER_AMOUNT = 4'd5,
BALANCE_ENQUIRY = 4'd6,
    CURRENT_BALANCE = 4'd7,
    MINI_STATEMENT  = 4'd8,
PROCESSSING_TRANSACTION = 4'd9,
TRANSACTION_DONE = 4'd10,
ERROR = 4'd11;

reg [3:0] currentstate, nextstate;

task disp_eject_nextstate;
input [2:0] disp;
input eject;
input [3:0] ns;
begin
{display,card_eject,nextstate}= {disp,eject,ns};
end
endtask

always @(posedge clk, posedge reset) begin
if (reset) currentstate <= IDLE;
else currentstate <= nextstate;
end

always @(*) begin
    nextstate = currentstate;
    card_eject=0;
    display = 3'b00;
    cash_out = 0;receipt_out=0;transaction_success=0;
    case (currentstate)
        IDLE: disp_eject_nextstate(`Welcome_screen,`hold,card_in ? CARD_INSERTED : IDLE);
        CARD_INSERTED: disp_eject_nextstate(`Processing,`hold,ENTER_PIN);
        ENTER_PIN: disp_eject_nextstate(`Enter,`hold,VERIFY_PIN);
        VERIFY_PIN: disp_eject_nextstate(`Processing,`hold,pin_check ? MENU : ERROR );
        MENU:disp_eject_nextstate(`Select, `hold,withdraw1_or_balanceenq0 ? ENTER_AMOUNT : BALANCE_ENQUIRY);
        ENTER_AMOUNT :disp_eject_nextstate(`Enter,`hold, amount ? PROCESSSING_TRANSACTION : ERROR );
        PROCESSSING_TRANSACTION: begin 
        disp_eject_nextstate(`Processing,`hold,transaction_success ? TRANSACTION_DONE: currentstate);
        end
        TRANSACTION_DONE: disp_eject_nextstate(`Success_and_newtransaction,`release,new_transaction ? MENU : IDLE);
        
        BALANCE_ENQUIRY: disp_eject_nextstate(`Select,`hold,currentbalance1_ministatement0? CURRENT_BALANCE: MINI_STATEMENT);
        CURRENT_BALANCE: begin
                            if (balance_enquiry_success) begin
                             disp_eject_nextstate(`Success_and_newtransaction,~new_transaction ,new_transaction ? MENU:IDLE );
                             receipt_out = 1;
                             end
                            else disp_eject_nextstate(`Error,`release , IDLE );
                         end
        MINI_STATEMENT: begin
                            if (balance_enquiry_success) begin
                             disp_eject_nextstate(`Success_and_newtransaction,~new_transaction ,new_transaction ? MENU:IDLE );
                             receipt_out = 1;
                             end
                            else disp_eject_nextstate(`Error,`release , IDLE );
                         end
        ERROR: disp_eject_nextstate(`Error,`release,IDLE);
        default: disp_eject_nextstate(`Welcome_screen,`release,IDLE);
    endcase
    cash_out = transaction_success;
end
endmodule
