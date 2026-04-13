# agenix: add a new env secret

This repo uses `agenix` to store encrypted env files in git.

## Pattern

In `hosts/think/default.nix`, use this helper pattern:

```nix
let
  mkSecret = file: {
    file = ../../secrets/${file};
    owner = "joohoon";
    mode = "0400";
  };
in
{
  age.secrets.<name> = mkSecret "<name>.env.age";
}
```

## Add a new secret

### 1. Add the file to `secrets.nix`

```nix
let
  joohoon = "ssh-ed25519 AAAA...your-public-key...";
in
{
  "secrets/<name>.env.age".publicKeys = [ joohoon ];
}
```

### 2. Declare it in `hosts/think/default.nix`

```nix
age.secrets.<name> = mkSecret "<name>.env.age";
```

### 3. Create or edit the encrypted file

```bash
agenix -e secrets/<name>.env.age
```

Put env-style values inside:

```env
OPENAI_API_KEY=sk-xxxx
ANTHROPIC_API_KEY=sk-yyyy
```

Save and exit.

### 4. Rebuild

```bash
sudo nixos-rebuild switch --flake .#think
```

The decrypted file will be available at:

```bash
/run/agenix/<name>
```

## Use it

### Shell

```bash
set -a
source /run/agenix/<name>
set +a
```

### systemd service

```nix
serviceConfig.EnvironmentFile = config.age.secrets.<name>.path;
```

## Checklist

- Add `"secrets/<name>.env.age"` to `secrets.nix`
- Add `age.secrets.<name> = mkSecret "<name>.env.age";`
- Run `agenix -e secrets/<name>.env.age`
- Add `KEY=value` lines
- Rebuild with `sudo nixos-rebuild switch --flake .#think`
- Use `/run/agenix/<name>` in shell or service
