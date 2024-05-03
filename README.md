# Docker image of PHP_CodeSniffer (PHPCS) for Drupal

The Docker image includes:

- PHPCS: <https://github.com/squizlabs/PHP_CodeSniffer>
- Gitlab Report for PHP_CodeSniffer: <https://github.com/micheh/phpcs-gitlab>
- Drupal Coder: <https://www.drupal.org/project/coder>

## Example usage on Gitlab CI pipeline

```yaml
phpcs:
  stage: code-quality
  only:
    - merge_requests
  allow_failure: true
  image:
    name: "quintux/phpcs-drupal"
    entrypoint: [""]
  before_script:
    - git fetch
    - php --version
    - composer global update --with-dependencies drupal/coder
  script:
    - echo -n "" > /output/filelist.txt
    # Only check changed files in merge requests
    - git diff --name-only origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME | while read F; do test -f "$F" && echo "$F" >> /output/filelist.txt ; done
    - phpcs --standard=Drupal,DrupalPractice --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md,yml --basepath=. --file-list=/output/filelist.txt --report=full --report-\\Micheh\\PhpCodeSniffer\\Report\\Gitlab=.ci/phpcs-quality-report.json
  artifacts:
    paths:
      - ".ci/phpcs-quality-report.json"
    expire_in: 14 days
    when: always
    reports:
      codequality: .ci/phpcs-quality-report.json
```
