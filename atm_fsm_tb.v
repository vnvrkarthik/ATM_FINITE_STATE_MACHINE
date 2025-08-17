`timescale 1ns / 1ps

module atm_fsm_tb;

    // Testbench signals
    reg clk, reset;
    reg card_in, pin_check, withdraw1_or_balanceenq0, currentbalance1_ministatement0;
    reg amount, transaction_success, balance_enquiry_success, new_transaction;
    wire card_eject, cash_out, receipt_out;
    wire [2:0] display;

    // Instantiate the DUT
    atm_fsm uut (
        .clk(clk),
        .reset(reset),
        .card_in(card_in),
        .pin_check(pin_check),
        .withdraw1_or_balanceenq0(withdraw1_or_balanceenq0),
        .currentbalance1_ministatement0(currentbalance1_ministatement0),
        .amount(amount),
        .transaction_success(transaction_success),
        .balance_enquiry_success(balance_enquiry_success),
        .new_transaction(new_transaction),
        .card_eject(card_eject),
        .cash_out(cash_out),
        .receipt_out(receipt_out),
        .display(display)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        card_in = 0;
        pin_check = 0;
        withdraw1_or_balanceenq0 = 0;
        currentbalance1_ministatement0 = 0;
        amount = 0;
        transaction_success = 0;
        balance_enquiry_success = 0;
        new_transaction = 0;

        // Hold reset for a few cycles
        #10 reset = 0;

        // 1. Insert card
        #10 card_in = 1;

        // 2. Correct PIN
        #20 pin_check = 1;

        // 3. Withdraw operation
        #20 withdraw1_or_balanceenq0 = 1;

        // 4. Enter amount
        #20 amount = 1;

        // 5. Transaction success
        #20 transaction_success = 1;

        // 6. Request new transaction
        #20 new_transaction = 1;

        // 7. Switch to balance enquiry
        #20 withdraw1_or_balanceenq0 = 0;
        #10 currentbalance1_ministatement0 = 1;
        #10 balance_enquiry_success = 1;

        // 8. End simulation
        #50 $finish;
    end

    // Monitor signals for debug
    initial begin
        $monitor("T=%0t | State Display=%b | Card Eject=%b | Cash Out=%b | Receipt=%b",
                  $time, display, card_eject, cash_out, receipt_out);
    end

endmodule
