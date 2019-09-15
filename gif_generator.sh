#!/bin/bash

usage()
{
cat << EOF
gif_generator.sh <options> -g <output_gif_file>

OPTIONS:
   -h         Show this message
   -v [arg]   Path to video file
   -g [arg]   File to output gif
   -i [arg]   Path to folder with static images
   -o         Optimize gif, save to 'opt_<gif name>'
   -c         Clean image folder before and after.
              Defaults to false, true recommended for videos.
EOF
exit
}


VIDEO=""
GIF=""
OPT=false
IMG="/tmp/gif_generator"
CLEAN=false
GetOpts()
{
  argv=()
  while [ $# -gt 0 ]
  do
    opt=$1
    shift
    case ${opt} in
        -v)
          if [ $# -eq 0 -o "${1:0:1}" = "-" ]
          then
            echo "Specify a video with -v"
          else
            VIDEO="$1"
          fi
          shift
          ;;
        -g)
          if [ $# -eq 0 -o "${1:0:1}" = "-" ]
          then
            echo "Specify a GIF with -g"
          else
            GIF="$1"
          fi
          shift
          ;;
        -o)
          OPT=true
          ;;
        -c)
          CLEAN=true
          ;;
        -i)
          if [ $# -eq 0 -o "${1:0:1}" = "-" ]
          then
            echo "Specify an image folder with -i"
          else
            IMG="$1"
          fi
          shift
          ;;
        *)
          usage
          argv+=(${opt})
          ;;
    esac
  done
}

GetOpts $*

echo "Video to GIF!"
echo "    -Video:        $VIDEO"
echo "    -GIF:          $GIF"
echo "    -Image folder: $IMG"
echo "    -Optimize gif: $OPT"
echo "    -Clean:        $CLEAN"

# Video to images
if [[ "$VIDEO" != "" ]]
then

  if [[ "$CLEAN" == true ]]
  then
    echo "Clean up image folder["$IMG"]"
    rm -rf $IMG/*
  fi

  echo "Converting video file ["$VIDEO"] to still images."
  mplayer -ao null $VIDEO -vo jpeg:outdir=$IMG

  echo "Still images saved at [" $IMG "]."
fi

# Images to gif
if [[ "$GIF" != "" ]]
then
  echo "Converting still images to GIF ["$GIF"]."
  convert -delay 10 -dispose Background $IMG/* $GIF

  if [[ "$CLEAN" == true ]]
  then
    echo "Clean up image folder["$IMG"]"
    rm -rf $IMG
  fi

  echo "Gif saved at [" $GIF "]."
fi

if [[ "$OPT" == true ]]
then
  echo "Optimizing GIF ["$GIF"]."
  convert $GIF -fuzz 10% -layers Optimize "opt_$GIF"

  echo "Optimized GIF saved at [opt_"$GIF"]."
fi

echo "Done"

