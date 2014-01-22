mkdir selected
head -$1 clusters | cut -d " " -f 3 | xargs -i cp models/'{}' selected
