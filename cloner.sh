for repo in $(curl -s --header "PRIVATE-TOKEN: $1" \
    "https://gitlab.com/api/v4/groups/$2/projects?include_subgroups=true&page=1&per_page=100" |
    jq -r '.[] | "\(.path_with_namespace)#\(.ssh_url_to_repo)"'); do
    dir=$(echo $repo | cut -d "#" -f 1)
    link=$(echo $repo | cut -d "#" -f 2)
    mkdir -p $dir
    git clone $link $dir
done
