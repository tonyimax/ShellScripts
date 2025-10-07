ffmpeg -i test.265 -vf "scale=1280:-2, fps=60" -c:v libx265 -preset medium -crf 23 -an test_720p.265
