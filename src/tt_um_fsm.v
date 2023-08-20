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

    wire reset = ! rst_n;
    reg [7:0] led_out;
    reg [2:0] state_reg = 3'd0;
    assign uo_out[7:0] = led_out;
    // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;
    reg done;
    reg [1:0] state;

    // Parámetros para los estados
    localparam IDLE = 2'b00;
    localparam COUNT = 2'b01;
    localparam RESET = 2'b10;

    // Registros de estado y próximo estado
    reg [1:0] current_state, next_state;

    assign uio_out[7:0] = current_state;

    // Contador
    reg [3:0] counter;

    // Lógica de la máquina de estados
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            counter <= 4'b0000;
            done <= 1'b0;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (ena) begin
                    next_state = COUNT;
                end else begin
                    next_state = IDLE;
                end
            end
            COUNT: begin
                if (counter == 4'b0011) begin
                    next_state = RESET;
                end else begin
                    next_state = COUNT;
                end
            end
            RESET: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Salidas basadas en el estado
    always @(posedge clk) begin
        case (current_state)
            IDLE: begin
                done <= 1'b0;
                led_out <= 8'd10;
            end
            COUNT: begin
                counter <= counter + 1;
                done <= 1'b0;
                led_out <= 8'd5;
            end
            RESET: begin
                counter <= 4'b0000;
                done <= 1'b1;
                led_out <= 8'd15;
            end
            default: begin
                done <= 1'b0;
                led_out <= 8'd3;
            end
        endcase
    end

    // Asignar el estado actual a la salida
    always @(*) begin
        state = current_state;
    end

endmodule
