# Make Alpine Linux APK Package Index

This action builds an Alpine Linux package repository from a set of github
projects using [goreleaser](https://goreleaser.com/).

## Inputs

## `projects`

**Required** The projects to include. They need to be in the form
`group/project`.

## `signature_key`

**Required** The RSA private key to sign the repository.

## `signature_key_name`

**Required** The signature key name. It needs to match the name of the public
key that is installed in `/etc/apk/keys`. For instance, if the public key
filename is `kaweezle-devel@kaweezle.com-c9d89864.rsa.pub`, the name of the key
should be `kaweezle-devel@kaweezle.com-c9d89864.rsa`.

## `destination`

**Required** The directory where to create the repo. Default is `"repo"`.

## Outputs

None.

## APK file names

The action expects the APK file name to have the following syntax:

```
<package_name>-<version>.<arch>.apk
```

For instance:

```
iknite-0.1.8.x86_64.apk
```

## Example usage

```yaml
# Build the repo
- name: Build APK repo
  uses: ./.github/actions/make-apkindex
  with:
    projects: kaweezle/iknite kaweezle/krmfnsops
    signature_key: '${{ secrets.GPG_PRIVATE_KEY }}'
    signature_key_name: kaweezle-devel@kaweezle.com-c9d89864.rsa
    destination: docs/repo

# Commit back the repo
- name: Commit APK repo
  uses: EndBug/add-and-commit@v9
  with:
    message: Rebuilding APK repo
    add: docs/repo
```
