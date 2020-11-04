#!/bin/sh

#IPFS_GATEWAY
export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"

# LOTUS Daemon Dir
export LOTUS_PATH=/filecoin/.lotus
# LOTUS Miner Dir
export LOTUS_MINER_PATH=/filecoin/lotusminer

# Lotus Miner Seal TMP 
# Lotus Worker use the same seal tmp for command line
export TMPDIR=/filecoin/seal-TMP

# LOTUS Miner Performance
# See https://github.com/filecoin-project/bellman
export BELLMAN_CPU_UTILIZATION=0.875
# See https://github.com/filecoin-project/rust-fil-proofs/
export FIL_PROOFS_MAXIMIZE_CACHING=1
# LOTUS Miner CPU & GPU Available
export BELLMAN_CUSTOM_GPU="GeForce RTX 3080:8704"
# More speed at RAM cost (1x sector-size of RAM - 32 GB).
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
# precommit2 GPU acceleration
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1

# Lotus Miner Parameter Path
export FIL_PROOFS_PARAMETER_CACHE=/filecoin/filecoin-proof-parameters
export FIL_PROOFS_PARENT_CACHE=/filecoin/filecoin-parents

# just enable flag
export filecoin_flag=2

/usr/local/bin/lotus-miner backup /data4/lotus-miner-metadata-backup/$(date +%Y%m%d)
