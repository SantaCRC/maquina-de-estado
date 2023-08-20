`default_nettype none

module tt_um_fsm #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg [7:0] led_out;
    assign uo_out[7:0] = led_out;
    // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;
    reg [7:0] counter = 8'd0;

    // FSM states
    localparam [2:0] S_IDLE = 3'b000;
    localparam [2:0] S_COUNT = 3'b001;
    localparam [2:0] S_WAIT  = 3'b010;
    localparam [2:0] S_DONE  = 3'b011;

    // FSM state register
    reg [2:0] state_reg;
    // FSM next state logic
    always @(posedge clk or negedge reset) begin
        if (!rst_n) begin
            state_reg <= S_IDLE;
        end else begin
            case (state_reg)
                S_IDLE: begin
                    if (ena) begin
                        state_reg <= S_COUNT;
                    end else begin
                        state_reg <= S_IDLE;
                    end
                end
                S_COUNT: begin
                    if (counter == 3'd3) begin
                        state_reg <= S_WAIT;
                    end else begin
                        state_reg <= S_COUNT;
                    end
                end
                S_WAIT: begin
                    if (ena) begin
                        state_reg <= S_DONE;
                    end else begin
                        state_reg <= S_WAIT;
                    end
                end
                S_DONE: begin
                    if (ena) begin
                        state_reg <= S_IDLE;
                    end else begin
                        state_reg <= S_DONE;
                    end
                end
                default: begin
                    state_reg <= S_IDLE;
                end
            endcase
        end
    end

    // FSM output logic
    always @(posedge clk or negedge clk) begin
        case (state_reg)
            S_IDLE: begin
                counter <= 0;
                led_out = 8'd0;
            end
            S_COUNT: begin
                counter <= counter + 1;
                led_out = 8'd10;
            end
            S_WAIT: begin
                led_out = 8'd5;
            end
            S_DONE: begin
                led_out = 8'd15;
            end
            default: begin
                led_out = 8'd17;
            end
        endcase
    end

endmodule
