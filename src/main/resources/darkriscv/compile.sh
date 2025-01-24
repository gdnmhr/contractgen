set -ax

cd "$1" || exit
export LR_VERIF_OUT_DIR=$2
rm -r "$LR_VERIF_OUT_DIR"
mkdir -p "$LR_VERIF_OUT_DIR"

#cp $1/core/* $LR_VERIF_OUT_DIR

#-------------------------------------------------------------------------
# use sv2v to convert all SystemVerilog files to Verilog
#-------------------------------------------------------------------------
export directories=( \
      "verif/*.sv" \
    );

# Print array values in  lines
for file in ${directories[*]}; do
  module=$(basename -s .sv "$file")
  if [[ "$module" == *_pkg ]]; then
    continue
  fi
  if [[ "$module" == *_intf ]]; then
    continue
  fi
  sv2v -v \
    --define=SYNTHESIS \
    --define=CONTRACT \
    --define=RISCV_FORMAL \
    "$file" \
    > "$LR_VERIF_OUT_DIR"/"${module}".v
done

export directories2=( \
      "core/*.v" \
    );

# Print array values in  lines
for file in ${directories2[*]}; do
  module=$(basename -s .v "$file")
  if [[ "$module" == *_pkg ]]; then
    continue
  fi
  if [[ "$module" == *_intf ]]; then
    continue
  fi
  sv2v -v \
    --define=SYNTHESIS \
    --define=CONTRACT \
    --define=RISCV_FORMAL \
    --define=VERIFICATION \
    -I./core/config_2stages.vh \
    "$file" \
    > "$LR_VERIF_OUT_DIR"/"${module}".v
done


# Insert content from formal.prop into generated top.v as sv2v would remove it
sed -i '/endmodule/i MARKER' "$LR_VERIF_OUT_DIR"/top.v
sed -i -e '/MARKER/e cat verif\/formal.prop' -e '/MARKER/d' "$LR_VERIF_OUT_DIR"/top.v

# Read initial memory content from files
# shellcheck disable=SC2016
sed -i '/\/\/ Trace: verif\/instr_mem.sv:32:9/i $readmemh({"init_", $sformatf("%0d", ID), ".dat"}, mem, 0, 31);' "$LR_VERIF_OUT_DIR"/instr_mem.v
# shellcheck disable=SC2016
sed -i '/\/\/ Trace: verif\/instr_mem.sv:32:9/i $readmemh({"memory_", $sformatf("%0d", ID), ".dat"}, mem, 32, (128 - 1));' "$LR_VERIF_OUT_DIR"/instr_mem.v

# shellcheck disable=SC2016
sed -i '/\/\/ Trace: verif\/control.sv:22:9/i $readmemh({"count.dat"}, counters, 0, 0);' "$LR_VERIF_OUT_DIR"/control.v

cd "$LR_VERIF_OUT_DIR"/ || exit

# shellcheck disable=SC2035
iverilog -o darkriscv *.v