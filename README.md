![CI](https://github.com/ThiagoAnunciacao/s3cmd-sync-action/workflows/CI/badge.svg)

# GitHub Action to Sync S3 Bucket using s3cmd 🔄

This action uses the [s3cmd](https://s3tools.org/usage) to sync a directory (either from your repository or generated during your workflow) with a remote S3 bucket.

By default this action difers from the all founds in github actions market place, because has some very useful options like cloudFront invalidation files, not only for entire directory `/*` but only files that should has too by invalidate, and no need to use CF destination Id's as well.

Other very useful and very recommended options is settings cache headers for assets, this can help to improve the performance of your site and reduce running costs of your aws account.


## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)


```yaml
name: Publish

on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: ThiagoAnunciacao/s3cmd-sync-action@v0.2.4
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_REGION: 'us-east-1'        # optional: defaults to us-east-1
        S3CMD_SOURCE_DIR: 'compiled'   # optional: defaults ./ to entire repository
        S3CMD_EXCLUDE: '.git/*'        # optional: defaults empty
        S3CMD_EXCLUDE_FROM: ''         # optional: defaults empty
        S3CMD_DELETE_REMOVED: 'true'   # optional: default true
        S3CMD_ADD_HEADERS: ''          # optional: defaults empty
        S3CMD_CF_INVALIDATE: 'true'    # optional: default true
        S3CMD_EXTRA_OPTS: '--verbose'  # optional: default --verbose
```


### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information, especially `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, should be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

| Key                     | Value                                                                                                                                                                                                                       | Suggested Type | Required | Default                                       |                                                         |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------|-----------------------------------------------|---------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)                                                                                                         | `secret env`   | **Yes**  | N/A                                           |                                                         |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)                                                                                                  | `secret env`   | **Yes**  | N/A                                           |                                                         |
| `AWS_S3_BUCKET`         | The name of the bucket you're syncing to. For example, `s3website.com` or `my-app-releases`.                                                                                                                                | `secret env`   | **Yes**  | N/A                                           |                                                         |
| `AWS_REGION`            | The region where you created your bucket. Set to `us-east-1` by default. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env`          | No       | `us-east-1`                                   |                                                         |
| `S3CMD_SOURCE_DIR`      | The local directory (or file) you wish to sync/upload to S3. For example, `public`. Defaults to your entire repository.                                                                                                     | `env`          | No       | `./` (root of cloned repository)              |                                                         |
| `S3CMD_EXCLUDE`         | Filenames and paths matching GLOB will be excluded.                                                                                                                                                                         | `env`          | No       | N/A                                           |                                                         |
| `S3CMD_EXCLUDE_FROM`    | Read --exclude GLOBs from FILE.                                                                                                                                                                                             | `env`          | No       | N/A                                           |                                                         |
| `S3CMD_DELETE_REMOVED`  | Delete destination objects with no corresponding source file [sync].                                                                                                                                                        | `env`          | No       | `true`                                        |                                                         |
| `S3CMD_ADD_HEADERS`     | Add a given HTTP header to the upload request. Give values separeted by `|` (pipes)                                                                                                                                         | `env`          | No       | `Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT | Cache-Control:max-age=31556952` (one year)            | |
| `S3CMD_CF_INVALIDATE`   | Invalidate the uploaded filed in CloudFront.                                                                                                                                                                                | `env`          | No       | `true`                                        |                                                         |
| `S3CMD_EXTRA_OPTS`      | Some other useful options that could be used [More info here.](https://s3tools.org/usage).                                                                                                                                  | `env`          | No       | `--verbose`                                   |                                                         |


## License

This project is distributed under the [MIT license](LICENSE.md).
