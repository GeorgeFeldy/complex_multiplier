
import numpy as np 
import random

seed = 123 # keep seed 

awidth = 16 

op1_ba     = 500    # first operand base address
op2_ba     = 1500  # second operand base address
#op2_ba     = 4500  # result ba 
exp_res_ba = 6500  # expected result base address
nr_op      = 300   # total number of operations 

random.seed(seed, version=2) # set to constant seed 

fe = open("expected.txt", "w") # expected file 

#max_addr = max(op1_ba, op2_ba, exp_res_ba)
array = np.zeros((2**awidth, 1), dtype=bytes) # initialize memory array 

for i in range(0, nr_op * 2, 2):  # use this for py_ver < 3.9:
    x1 = random.randbytes(1)      # np.random.bytes(1)  
    y1 = random.randbytes(1)      # np.random.bytes(1)  
    x2 = random.randbytes(1)      # np.random.bytes(1)  
    y2 = random.randbytes(1)      # np.random.bytes(1)  

    # parse generated bytes as signed int
    l_x1 = int.from_bytes(x1, "little", signed = True)  
    l_y1 = int.from_bytes(y1, "little", signed = True) 
    l_x2 = int.from_bytes(x2, "little", signed = True) 
    l_y2 = int.from_bytes(y2, "little", signed = True) 

    array[op1_ba + i    , 0] = x1
    array[op1_ba + i + 1, 0] = y1
    array[op2_ba + i    , 0] = x2
    array[op2_ba + i + 1, 0] = y2

    xr = l_x1 * l_x2 - l_y1 * l_y2  # compute result real part
    yr = l_x1 * l_y2 + l_y1 * l_x2  # compute result imaginary part 

    # get operation as string
    res_str = "(" + str(l_x1) + " + " + str(l_y1) + "i) * (" + str(l_x2) + " + " + str(l_y2) + "i) = (" + str(xr) + " + " + str(yr) + "i)\n"

    print(res_str, end = '') 
    fe.write(res_str)

    print(xr.to_bytes(3, "little", signed=True).hex())
    print(yr.to_bytes(3, "little", signed=True).hex())

    # convert results to bytes 
    xr_e = (xr & 0x30000) >> 16 # sign extension 
    xr_h = (xr & 0x0FF00) >> 8  # high 
    xr_l = (xr & 0x000FF)       # low 

    yr_e = (yr & 0x30000) >> 16 # sign extension 
    yr_h = (yr & 0x0FF00) >> 8  # high 
    yr_l = (yr & 0x000FF)       # low 

    # write expected result as bytes at specified base address {xr, yr}, little endian
    array[exp_res_ba + i*3 + 0, 0] = xr_l.to_bytes(1, "little") 
    array[exp_res_ba + i*3 + 1, 0] = xr_h.to_bytes(1, "little") 
    array[exp_res_ba + i*3 + 2, 0] = xr_e.to_bytes(1, "little") 
    array[exp_res_ba + i*3 + 3, 0] = yr_l.to_bytes(1, "little") 
    array[exp_res_ba + i*3 + 4, 0] = yr_h.to_bytes(1, "little") 
    array[exp_res_ba + i*3 + 5, 0] = yr_e.to_bytes(1, "little") 

fb = open('mem.raw', "wb")
array.tofile(fb)

fb = open('mem.raw', "rb")
hexdata = fb.read().hex()


ft = open('mem.hex', "w")
for idx in range(0, len(hexdata)):
    ft.write(hexdata[idx])
    if(idx % 2 == 1) :
        ft.write('\n')


fe.close()
fb.close()
ft.close()



    

