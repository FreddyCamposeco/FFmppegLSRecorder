#!/bin/sh
# FFmppeg Linux Screen Recorder V0.401
# HEVEC libx265 60fps + System Audio flac
# 
# Sript By FreddyCS for Archlinux GNU/Linux 2020
#
# Screen Display and System Audio
# ffmpeg -f pulse -i $REC_system -c:a dca -f x11grab -i :0.0 -framerate 59.978 -s $SCREEN_res -c:v libx265 -preset ultrafast -crf 20 -threads 0 -strict -2  $DIR$NOM$DATE.mkv

# Mic Record Audio
# ffmpeg -f pulse -i $REC_mic -c:a dca -strict -2 $DIR$NOM$DATE.mkv

# Stereo merge
# ffmpeg -f pulse -i $REC_mic -f pulse -i $REC_system -filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0<c0+c2|c1<c1+c3[a]" -map "[a]" -c:a dca -strict -2 $DIR$NOM$DATE.mkv

# 5.1 map
# channel_layout=5.1:map=0.0-FL|1.0-FR|2.0-FC|3.0-LFE|4.0-BL|5.0-BR[a]
# ffmpeg -f pulse -i $REC_system  -f pulse -i $REC_mic -filter_complex "[0:a][0:a][1:a]join=inputs=3:channel_layout=5.1:map=0.0-FL|1.0-FR|2.0-FC[a]" -map "[a]" -c:a dca -strict -2 $DIR$NOM$DATE.mkv

clear

DATE=$(date | awk 'BEGIN{S="-"} {print $4 S $5}')
echo $DATE

DIR=$'/home/freddy/NAS/opt/Record/'
echo $DIR
NOM=$'RecordScreen_'
echo $NOM
FILE=$(echo $DIR$NOM$DATE.mkv)

SCREEN_res=$(xrandr -q --current | grep 'primary' | awk '{print$4}' | awk 'BEGIN{FS="+"} {print$1}')
echo $SCREEN_res
SCREEN_rate="60.000"
#RECORD_rate="59.956"
RECORD_rate=$SCREEN_rate
echo $SCREEN_rate

REC_system=$(pactl list sources short | awk '{print$2}' | grep '.monitor')
echo $REC_system
REC_mic=$(pactl list sources short | awk '{print$2}' | grep -i 'usb' | grep -i 'microphone')
echo $REC_mic

FILTER_a21="[1:a][1:a][2:a]join=inputs=3:channel_layout=5.1:map=0.0-FL|1.0-FR|2.0-FC[a]"
FILTER_a22="[1:a][2:a]amerge=inputs=2,pan=stereo|c0<c0+c2|c1<c1+c3[a]"
MAP_a="[a]"

# Screen Display + System Aduio + Mic | 3 chanels audio
#            -r $SCREEN_rate \

ffmpeg -fflags +igndts -init_hw_device vaapi=foo:/dev/dri/renderD128\
        -f x11grab \
            -s $SCREEN_res \
            -framerate $RECORD_rate \
            -i :0.0 \
        -f pulse \
            -i $REC_system \
        -f pulse \
            -i $REC_mic \
        -map 0:v \
            -c:v libx265 \
            -crf 20 \
            -preset ultrafast \
        -filter_complex $FILTER_a21 \
        -map $MAP_a \
            -c:a dca \
        -strict -2 \
        -threads 0 \
$FILE
#EOL
