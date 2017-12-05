#!/bin/sh
file=$1
max_aMax=$2
max_rMax=$3
ruleiters=""

function geniters()
{
  max=$1
  iters=""
  for ((i=1;i<=10&&i<=$max;i++))
  do
    iters="$iters $i"
  done
  for ((i=12;i<=20&&i<=$max;i+=2))
  do
    iters="$iters $i"
  done
  for ((i=40;i<=$max;i*=2))
  do
    iters="$iters $i"
  done

  echo "$iters"
}
aiters=`geniters $max_aMax`
riters=`geniters $max_rMax`
echo "aiters=$aiters"
echo "riters=$riters"
for i in $riters
do
  for j in $aiters
  do
    echo julia main.jl $file --aMax=$j --rMax=$i
    julia main.jl $file --aMax=$j --rMax=$i
  done
done
