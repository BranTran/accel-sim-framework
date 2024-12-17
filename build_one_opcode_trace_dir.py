import os
import shutil

# Define the hardcoded multiline formatted variable as a template
template = """
#BEGIN_TB
thread block = {thread_block},0,0

warp = 0
insts = 2
0000 {opcode_line}
0010 ffffffff 0 EXIT 0 0

#END_TB
"""

# Dictionary with opcode information
opcode_sass_line_dict = {
    "S2R":  "ffffffff 1 R0 S2R 0 0",
    "DEPBAR_LE": "ffffffff 0 DEPBAR.LE 0 0",
    "BSYNC": "ffffffff 0 BSYNC 0 0",
    "BSSY": "ffffffff 0 BSSY 0 0",
    "BMOV_32_CLEAR": "ffffffff 1 R0 BMOV.32.CLEAR 0 0",
    "BREAK": "00000000 0 BREAK 0 0",
    "RET_REL_NODEC": "00000001 1 R20 RET.REL.NODEC 0 0",
    "CALL_REL_NOINC": "ffffffff 0 CALL.REL.NOINC 0 0",
    "EXIT": "ffffffff 0 EXIT 0 0",
}

# Define header for kernel-1.traceg
trace_header = """-kernel name = _BranTranTest-{opcode}_
-kernel id = 1
-grid dim = (80,1,1)
-block dim = (32,1,1)
-shmem = 0
-nregs = 30
-binary version = 70
-cuda stream id = 0
-shmem base_addr = 0x0000200003000000
-local mem base_addr = 0x0000200005000000
-nvbit version = 1.5.3
-accelsim tracer version = 3

#traces format = threadblock_x threadblock_y threadblock_z warpid_tb PC mask dest_num [reg_dests] opcode src_num [reg_srcs] mem_width [adrrescompress?] [mem_addresses]




"""

# Create the root directory if it doesn't exist
root_dir = "one_op_traces"
os.makedirs(root_dir, exist_ok=True)

# Hardcoded file paths to copy
config_files = ["BT_one_cycle_mcpat_sass_sim_gpgpusim.config",
                 "gpu-simulator/gpgpu-sim/configs/tested-cfgs/SM7_GV100/accelwattch_sass_sim.xml",
                 "./run_sim.sh"]

# Iterate over the opcodes in the dictionary
for opcode, opcode_line in opcode_sass_line_dict.items():
    # Create a directory for each opcode
    opcode_dir = os.path.join(root_dir, opcode)
    os.makedirs(opcode_dir, exist_ok=True)
    
    # Copy configuration files into the opcode directory
    for config_file in config_files:
        if os.path.exists(config_file):
            shutil.copy(config_file, opcode_dir)
        else:
            print(f"Warning: {config_file} does not exist and will be skipped.")
    
    # Create a trace/ folder inside the opcode directory
    trace_dir = os.path.join(opcode_dir, "trace")
    os.makedirs(trace_dir, exist_ok=True)
    
    # Create the kernelslist.g file inside trace/
    kernelslist_path = os.path.join(trace_dir, "kernelslist.g")
    with open(kernelslist_path, "w") as kernelslist_file:
        kernelslist_file.write("kernel-1.traceg\n")
    
    # Create the kernel-1.traceg file inside trace/
    trace_file_path = os.path.join(trace_dir, "kernel-1.traceg")
    with open(trace_file_path, "w") as trace_file:
        # Write the header
        trace_file.write(trace_header.format(opcode=opcode))
        
        # Generate and write the trace content for thread blocks 0 to 79
        for i in range(80):
            output = template.format(thread_block=i, opcode_line=opcode_line)
            trace_file.write(output)
