#!/bin/sh

echo "Running check"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ -n "${INPUT_PROPERTIES_FILE}" ]; then
  OPT_PROPERTIES_FILE="-p ${INPUT_PROPERTIES_FILE}"
fi

wget -O - -q https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${INPUT_CHECKSTYLE_VERSION}/checkstyle-${INPUT_CHECKSTYLE_VERSION}-all.jar > /checkstyle.jar

echo $INPUT_FILE_LIST

for input_file in ${INPUT_FILE_LIST}; do
  echo $input_file
done


total_violations=0
for input_file in ${INPUT_FILE_LIST}; do
  if [[ "$input_file" == *.java* ]]; then
    found_v=$(exec java -jar /checkstyle.jar "${input_file}" -c "${INPUT_CHECKSTYLE_CONFIG}" ${OPT_PROPERTIES_FILE} -f xml \
     | reviewdog -f=checkstyle \
          -name="${INPUT_TOOL_NAME}" \
          -reporter="${INPUT_REPORTER:-github-pr-check}" \
          -filter-mode="${INPUT_FILTER_MODE:-added}" \
          -fail-on-error="${INPUT_FAIL_ON_ERROR:-false}" \
          -level="${INPUT_LEVEL}" \
     | grep ': error:' \
     | wc -l)
    echo "Analysed \"${input_file}\" with ${found_v} violations found on edited lines"
    total_violations=$(($total_violations + $found_v))
  else 
    echo "Does not match \"${input_file}\""
  fi
done

echo "Total violations found: ${total_violations}"
echo ::set-output name=total_volations::"${total_violations}"

