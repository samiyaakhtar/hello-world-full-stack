function verify_access_token() {
    echo "VERIFYING PERSONAL ACCESS TOKEN"
    if [[ -z "$ACCESS_TOKEN_SECRET" ]]; then
        echo "Please set env var ACCESS_TOKEN_SECRET for git host: $GIT_HOST"
        exit 1
    fi
}
function verify_repo() {
    echo "CHECKING HLD/MANIFEST REPO URL"
    # shellcheck disable=SC2153
    if [[ -z "$REPO" ]]; then
        echo "HLD/MANIFEST REPO URL not specified in variable $REPO"
        exit 1
    fi
}

function init() {
    cp -r ./* "$HOME/"
    cd "$HOME"
}

# Initialize Helm
function helm_init() {
    echo "RUN HELM INIT"
    helm init --client-only
}

# Obtain version for Bedrock CLI
# If the version number is not provided, then download the latest
function get_bedrock_version() {
    # shellcheck disable=SC2153
    if [ -z "$VERSION" ]
    then
        # By default, the script will use the most recent non-prerelease, non-draft release Bedrock CLI
        CLI_VERSION_TO_DOWNLOAD=$(curl -s "https://api.github.com/repos/microsoft/bedrock-cli/releases/latest" | grep "tag_name" | sed -E 's/.*"([^"]+)".*/\1/')
    else
        echo "Bedrock CLI Version: $VERSION"
        CLI_VERSION_TO_DOWNLOAD=$VERSION
    fi
}

# Obtain OS to download the appropriate version of Bedrock CLI
function get_os_bedrock() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        eval "$1='linux'"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        eval "$1='macos'"
    elif [[ "$OSTYPE" == "msys" ]]; then
        eval "$1='win.exe'"
    else
        eval "$1='linux'"
    fi
}

# Download Bedrock CLI
function download_bedrock() {
    echo "DOWNLOADING BEDROCK CLI"
    echo "Latest CLI Version: $CLI_VERSION_TO_DOWNLOAD"
    os=''
    get_os_bedrock os
    bedrock_cli_wget=$(wget -SO- "https://github.com/microsoft/bedrock-cli/releases/download/$CLI_VERSION_TO_DOWNLOAD/bedrock-$os" 2>&1 | grep -E -i "302")
    if [[ $bedrock_cli_wget == *"302 Found"* ]]; then
    echo "Bedrock CLI $CLI_VERSION_TO_DOWNLOAD downloaded successfully."
    else
        echo "There was an error when downloading Bedrock CLI. Please check version number and try again."
    fi
    wget "https://github.com/microsoft/bedrock-cli/releases/download/$CLI_VERSION_TO_DOWNLOAD/bedrock-$os"
    mkdir bedrock
    mv bedrock-$os bedrock/bedrock
    chmod +x bedrock/bedrock 

    export PATH=$PATH:$HOME/bedrock
}

# Obtain version for Fabrikate
# If the version number is not provided, then download the latest
function get_fab_version() {
    # shellcheck disable=SC2153
    if [ -z "$VERSION" ]
    then
        # By default, the script will use the most recent non-prerelease, non-draft release Fabrikate
        VERSION_TO_DOWNLOAD=$(curl -s "https://api.github.com/repos/microsoft/fabrikate/releases/latest" | grep "tag_name" | sed -E 's/.*"([^"]+)".*/\1/')
    else
        echo "Fabrikate Version: $VERSION"
        VERSION_TO_DOWNLOAD=$VERSION
    fi
}

# Download Fabrikate
function download_fab() {
    echo "DOWNLOADING FABRIKATE"
    echo "Latest Fabrikate Version: $VERSION_TO_DOWNLOAD"
    os=''
    get_os os
    fab_wget=$(wget -SO- "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip" 2>&1 | grep -E -i "302")
    if [[ $fab_wget == *"302 Found"* ]]; then
       echo "Fabrikate $VERSION_TO_DOWNLOAD downloaded successfully."
    else
        echo "There was an error when downloading Fabrikate. Please check version number and try again."
    fi
    wget "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip"
    unzip "fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip" -d fab

    export PATH=$PATH:$HOME/fab
}

# Authenticate with Git
function git_connect() {
    cd "$HOME"
    # Remove http(s):// protocol from URL so we can insert PA token
    repo_url=$REPO
    repo_url="${repo_url#http://}"
    repo_url="${repo_url#https://}"

    echo "GIT CLONE: https://automated:<ACCESS_TOKEN_SECRET>@$repo_url"
    git clone "https://automated:$ACCESS_TOKEN_SECRET@$repo_url"
    retVal=$? && [ $retVal -ne 0 ] && exit $retVal

    # Extract repo name from url
    repo_url=$REPO
    repo=${repo_url##*/}
    repo_name=${repo%.*}

    cd "$repo_name"
    echo "GIT PULL ORIGIN MASTER"
    git pull origin master
}

# Obtain OS to download the appropriate version of Fabrikate
function get_os() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        eval "$1='linux'"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        eval "$1='darwin'"
    elif [[ "$OSTYPE" == "msys" ]]; then
        eval "$1='windows'"
    else
        eval "$1='linux'"
    fi
}

# Checks for changes and only commits if there are changes staged. Optionally can be configured to fail if called to commit and no changes are staged.
# First arg - commit message
# Second arg - "should error if there is nothing to commit" flag. Set to 0 if this behavior should be skipped and it will not error when there are no changes.
# Third arg - variable to check if changes were commited or not. Will be set to 1 if changes were made, 0 if not.
function git_commit_if_changes() {

    echo "GIT STATUS"
    git status

    echo "GIT ADD"
    git add -A

    commitSuccess=0
    if [[ $(git status --porcelain) ]] || [ -z "$2" ]; then
        echo "GIT COMMIT"
        git commit -m "$1"
        retVal=$?
        if [[ "$retVal" != "0" ]]; then
            echo "ERROR COMMITING CHANGES -- MAYBE: NO CHANGES STAGED"
            exit $retVal
        fi
        commitSuccess=1
    else
        echo "NOTHING TO COMMIT"
    fi
    echo "commitSuccess=$commitSuccess"
    printf -v $3 "$commitSuccess"
}

# Perform a Git push
function git_push() {
    # Remove http(s):// protocol from URL so we can insert PA token
    repo_url=$REPO
    repo_url="${repo_url#http://}"
    repo_url="${repo_url#https://}"

    # Git Pull to make sure we are up to date
    git pull "https://$ACCESS_TOKEN_SECRET@$repo_url"
        
    echo "GIT PUSH: https://<ACCESS_TOKEN_SECRET>@$repo_url"
    git push "https://$ACCESS_TOKEN_SECRET@$repo_url"
    retVal=$? && [ $retVal -ne 0 ] && exit $retVal
    echo "GIT STATUS"
    git status
}