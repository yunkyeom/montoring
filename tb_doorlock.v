`timescale 1ns / 1ps

module doorlock_tb;

    // --- Signal Declarations (Inputs to UUT) ---
    reg clk;
    reg n_rst;
    reg bt_1;
    reg bt_2;
    reg bt_3;
    reg cover;

    // --- Signal Declarations (Outputs from UUT) ---
    // FND outputs are still required for the port list, but we won't check them.
    wire [6:0] fnd_1;
    wire [6:0] fnd_2;
    wire [6:0] fnd_3;
    wire [1:0] led_o;
    wire [1:0] led_f;
    wire [3:0] led_state;

    // --- Component Instantiation (Unit Under Test) ---
    doorlock uut (
        .clk(clk),
        .n_rst(n_rst),
        .bt_1(bt_1),
        .bt_2(bt_2),
        .bt_3(bt_3),
        .cover(cover),
        .fnd_1(fnd_1),
        .fnd_2(fnd_2),
        .fnd_3(fnd_3),
        .led_o(led_o),
        .led_f(led_f),
        .led_state(led_state)
    );
    
    // --- Clock Generation ---
    parameter CLK_PERIOD = 10; // 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end



    // --- Stimulus Generation ---
    initial begin
        // 1. Initial Reset: Should go to S_0 (Stop)
        $display("--- Start Test: Initialization ---");
        n_rst = 0; // Active low reset
        bt_1 = 1; bt_2 = 1; bt_3 = 1; // Buttons off (High)
        cover = 0;
        #20 n_rst = 1; // Release reset
        #20 $display("Time %0t: Initial state is S_0 (led_state=%0d)", $time, led_state);
        
        // 2. SUCCESS Scenario: BT_2, BT_1, BT_3 (S_1 -> S_2 -> S_3 -> S_4)

        // 2a. S_0 -> S_1 (Cover Open)
        $display("--- Test 2a: S_0 -> S_1 (Cover Open) ---");
        cover = 1;
        #100 $display("Time %0t: Cover=1, State should be S_1 (led_state=%0d)", $time, led_state);

        // 2b. S_1 -> S_2 (Press BT_2)
        $display("--- Test 2b: S_1 -> S_2 (Correct button BT_2) ---");
        bt_2 = 0; // Press BT_2
        # (CLK_PERIOD) bt_2 = 1; // Release BT_2 (One clock cycle press for edge detection)
        #20 $display("Time %0t: State should be S_2 (led_state=%0d)", $time, led_state);
        
        // 2c. S_2 -> S_3 (Press BT_1)
        $display("--- Test 2c: S_2 -> S_3 (Correct button BT_1) ---");
        bt_1 = 0; // Press BT_1
        # (CLK_PERIOD) bt_1 = 1; // Release BT_1
        #20 $display("Time %0t: State should be S_3 (led_state=%0d)", $time, led_state);

        // 2d. S_3 -> S_4 (Press BT_3)
        $display("--- Test 2d: S_3 -> S_4 (Correct button BT_3) ---");
        bt_3 = 0; // Press BT_3
        # (CLK_PERIOD) bt_3 = 1; // Release BT_3
        #20 $display("Time %0t: Final Success: S_4 (led_state=%0d, led_o=%0d)", $time, led_state, led_o);
        
        // 2e. S_4 -> S_0 (Cover Close)
        $display("--- Test 2e: S_4 -> S_0 (Cover Close) ---");
        cover = 0;
        #20 $display("Time %0t: Cover=0, State should be S_0 (led_state=%0d)", $time, led_state);


        // 3. FAILURE Scenario: BT_1, BT_2, BT_3 (S_1 -> S_5 -> S_6 -> S_7)

        // 3a. S_0 -> S_1 (Cover Open)
        $display("--- Test 3a: S_0 -> S_1 (Cover Open) ---");
        cover = 1;
        #100 $display("Time %0t: Cover=1, State should be S_1 (led_state=%0d)", $time, led_state);
        
        // 3b. S_1 -> S_5 (Press BT_1 - Incorrect first digit)
        $display("--- Test 3b: S_1 -> S_5 (Incorrect button BT_1 or BT_3) ---");
        bt_1 = 0; 
        # (CLK_PERIOD) bt_1 = 1;
        #20 $display("Time %0t: State should be S_5 (led_state=%0d)", $time, led_state);
        
        // 3c. S_5 -> S_6 (Press BT_2)
        $display("--- Test 3c: S_5 -> S_6 (Any button press) ---");
        bt_2 = 0;
        # (CLK_PERIOD) bt_2 = 1;
        #20 $display("Time %0t: State should be S_6 (led_state=%0d)", $time, led_state);

        // 3d. S_6 -> S_7 (Press BT_3)
        $display("--- Test 3d: S_6 -> S_7 (Any button press) ---");
        bt_3 = 0;
        # (CLK_PERIOD) bt_3 = 1;
        #20 $display("Time %0t: Final Failure: S_7 (led_state=%0d, led_f=%0d)", $time, led_state, led_f);
        
        // 3e. S_7 -> S_0 (Cover Close)
        $display("--- Test 3e: S_7 -> S_0 (Cover Close) ---");
        cover = 0;
        #20 $display("Time %0t: Cover=0, State should be S_0 (led_state=%0d)", $time, led_state);

        #100 $finish;
    end
    
    // Optional: Monitor key signals for debugging
    initial begin
        $monitor("Time=%0t | State=%0d | bt_1_on=%0d bt_2_on=%0d bt_3_on=%0d | cover=%0d | LED_O=%0d LED_F=%0d",
                 $time, uut.c_state, uut.bt_1_on, uut.bt_2_on, uut.bt_3_on, cover, led_o, led_f);
    end

endmodule
