
import numpy as np 

awidth = 16 

op1_ba = 100
op2_ba = 200
exp_res_ba = 400
nr_op = 10 


#max_addr = max(op1_ba, op2_ba, exp_res_ba)
array = np.zeros((2**awidth, 1), dtype=bytes)

for i in range(0, nr_op * 2, 2):
    x1 = np.random.bytes(1)  
    y1 = np.random.bytes(1)  
    x2 = np.random.bytes(1)  
    y2 = np.random.bytes(1)  

    l_x1 = int.from_bytes(x1, "big", signed = True)
    l_y1 = int.from_bytes(y1, "big", signed = True)
    l_x2 = int.from_bytes(x2, "big", signed = True)
    l_y2 = int.from_bytes(y2, "big", signed = True)

    array[op1_ba + i    , 0] = x1.hex()
    array[op1_ba + i + 1, 0] = y1.hex() 
    array[op2_ba + i    , 0] = x2.hex()
    array[op2_ba + i + 1, 0] = y2.hex()

    xr = l_x1 * l_x2 - l_y1 * l_y2
    yr = l_x1 * l_y2 + l_y1 * l_x2

    xr_e = (xr & 0x30000) >> 16 # sign extension 
    xr_h = (xr & 0x0FF00) >> 8  # high 
    xr_l = (xr & 0x000FF)       # low 

    yr_e = (yr & 0x30000) >> 16 # sign extension 
    yr_h = (yr & 0x0FF00) >> 8  # high 
    yr_l = (yr & 0x000FF)       # low 

    array[exp_res_ba + i*3    , 0] = xr_e.to_bytes(1, "big") 
    array[exp_res_ba + i*3 + 1, 0] = xr_h.to_bytes(1, "big") 
    array[exp_res_ba + i*3 + 2, 0] = xr_l.to_bytes(1, "big") 
    array[exp_res_ba + i*3 + 3, 0] = yr_e.to_bytes(1, "big") 
    array[exp_res_ba + i*3 + 4, 0] = yr_h.to_bytes(1, "big") 
    array[exp_res_ba + i*3 + 5, 0] = yr_l.to_bytes(1, "big") 


fb = open('mem.raw', "wb")
array.tofile(fb)

fb = open('mem.raw', "rb")
hexdata = fb.read().hex()


ft = open('mem.hex', "w")
for idx in range(0, len(hexdata)):
    ft.write(hexdata[idx])
    if(idx % 2 == 1) :
        ft.write('\n')

fb.close()
ft.close()



    

