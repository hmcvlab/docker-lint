#!/bin/bash
set -e

# Local variables
if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
  project_root="$(git rev-parse --show-toplevel)"
else
  project_root="$(pwd)"
fi

# Parse flags if major, minor or patch should be increased
python_root="$project_root"
cpp_root="$project_root"
shell_root="$project_root"
#while [[ $# -gt 0 ]]; do
for i in "$@"; do
  case $1 in
  --python=*)
    python_root="${project_root}/${i#*=}"
    shift
    ;;
  --cpp=*)
    cpp_root="${project_root}/${i#*=}"
    shift
    ;;
  --shell=*)
    shell_root="${project_root}/${i#*=}"
    shift
    ;;
  --*)
    echo "Unknown option $i"
    exit 1
    ;;
  *) ;;
  esac
done

# Functions
ok() {
  printf "\e[32mok\e[0m\n"
}

header() {
  printf "\e[34mCheck \e[36m%s\e[34m files with '%s'...\e[0m" "$1" "$2"
}

skip() {
  printf "\e[33mskip\e[0m\n"
}

line() {
  # print horizontal line
  printf "\e[34m%s\e[0m\n" "----------------------------------------"
}

append_if_exists() {
  if [ -d "${project_root}/$1" ]; then
    printf "%s/%s" "$project_root" "$1"
  else
    printf "%s" "$project_root"
  fi
}

# If input arg set to project root
line
printf "Shell root: %s\n" "$shell_root"
printf "C++ root: %s\n" "$cpp_root"
printf "Python root %s\n" "$python_root"
if [ -f "${python_root}/pyproject.toml" ]; then
  project_name=$(python3 -c "import toml; print(toml.load('pyproject.toml')['project']['name'])")
  python_root=$(append_if_exists "$project_name")
  printf "New python root from pyproject.toml: %s\n" "$python_root"
fi
line

# Count files
n_shell="$(find "$shell_root" -name "*.sh" | wc -l)"
n_cpp="$(find "$cpp_root" -name "*.cpp" -o -name "*.h" | wc -l)"
n_python="$(find "$python_root" -name "*.py" | wc -l)"
n_yaml="$(find "$python_root" -name "*.yml" -o -name "*.yaml" | wc -l)"
n_docker="$(find "$python_root" -name "*Dockerfile*" | wc -l)"

# Linter: shellcheck
header "$n_shell" "shellcheck"
if [ "$n_shell" -gt 0 ]; then
  find "$shell_root" -name "*.sh" -print0 | xargs -0 shellcheck -e SC1090 -e SC1091
  ok
else
  skip
fi

if [ "$n_cpp" -gt 0 ]; then
  # Linter: cpplint
  header "$n_cpp" "cpplint"
  cpplint --recursive --quiet --filter=-build/c++11,-runtime/explicit "$cpp_root"
  ok

  # Linte: cppcheck
  header "$n_cpp" "cppcheck"
  cppcheck --quiet --enable=warning,style,performance,portability "$cpp_root"
  ok
else
  header "$n_cpp" "cpp"
  skip
fi

if [ "$n_python" -gt 0 ]; then
  # Linter: pylint
  header "$n_python" "pylint"
  pylint --recursive=true --score=n "$python_root"
  ok

  # Linter: flake8
  header "$n_python" "flake8"
  flake8 --append-config="/etc/flake8" "$project_root"
  ok
else
  header "$n_python" "python"
  skip
fi

# Linter: yamllint
header "$n_yaml" "yamllint"
if [[ "$n_yaml" -gt 0 ]]; then
  yamllint "$project_root"
  ok
else
  skip
fi

# Linter: hadolint
header "$n_docker" "hadolint"
if [[ "$n_docker" -gt 0 ]]; then
  find "$project_root" -name "*Dockerfile*" -print0 | xargs -0 hadolint \
    --ignore DL3006 \
    --ignore DL3008 \
    --ignore DL3033 \
    --ignore SC1091
  ok
else
  skip
fi

line
printf "\n"
