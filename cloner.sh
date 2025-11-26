for ((page=1; page<=15; page++)); do
    for repo in $(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        "https://gitlab.com/api/v4/groups/edukita/projects?include_subgroups=true&page=$page&per_page=100" |
        jq -r '.[] | "\(.path_with_namespace)#\(.http_url_to_repo)"'); do
        dir=$(echo $repo | cut -d "#" -f 1)
        link=$(echo $repo | cut -d "#" -f 2)
            echo "===="
            echo $dir
            echo $link
            mkdir -p $dir
            git clone $link $dir
            sleep 1
    done
done