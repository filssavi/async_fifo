//-----------------------------------------------------------------------------
// Copyright 2017 Damien Pretet ThotIP
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------------------  

`timescale 1 ns / 1 ps
`default_nettype none

module wptr_full

    #(
    parameter ASIZE = 4
    )(
    input  wire             wclk,
    input  wire             wrst_n,
    input  wire             winc,
    input  wire [ASIZE  :0] wq2_rptr,
    output reg              wfull,
    output reg              awfull,
    output wire [ASIZE-1:0] waddr,
    output reg  [ASIZE  :0] wptr
    );

    reg  [ASIZE:0] wbin;
    wire [ASIZE:0] wgraynext, wbinnext, wgraynextp1;
    wire              awfull_val, wfull_val;

    // GRAYSTYLE2 pointer
    always @(posedge wclk or negedge wrst_n) begin

        if (!wrst_n) 
            {wbin, wptr} <= 0;
        else         
            {wbin, wptr} <= {wbinnext, wgraynext};

    end
    
    // Memory write-address pointer (okay to use binary to address memory)
    assign waddr = wbin[ASIZE-1:0];
    assign wbinnext  = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;
    assign wgraynextp1 = ((wbinnext + 1'b1) >> 1) ^ (wbinnext + 1'b1);
    
    //------------------------------------------------------------------ 
    // Simplified version of the three necessary full-tests:
    // assign wfull_val=((wgnext[ASIZE] !=wq2_rptr[ASIZE] ) &&
    //                   (wgnext[ASIZE-1]  !=wq2_rptr[ASIZE-1]) &&
    // (wgnext[ASIZE-2:0]==wq2_rptr[ASIZE-2:0])); 
    //------------------------------------------------------------------
    
     assign wfull_val = (wgraynext == {~wq2_rptr[ASIZE:ASIZE-1],wq2_rptr[ASIZE-2:0]});
     assign awfull_val = (wgraynextp1 == {~wq2_rptr[ASIZE:ASIZE-1],wq2_rptr[ASIZE-2:0]});

     always @(posedge wclk or negedge wrst_n) begin

        if (!wrst_n) begin
            awfull <= 1'b0;
            wfull  <= 1'b0;
        end
        else begin
            awfull <= awfull_val;
            wfull  <= wfull_val;
        end

    end

endmodule

`resetall
