find ./android_x265_build -name "link.txt" -exec grep -l "-lpthread" {} \; | while read file; do
    echo "替换文件$file中内容:-lpthread为空"
    #sed -i '' 's/-lpthread/""/g' "$file"
done
