let
  joohoon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQkLoqczS2WkxWB1ysSnuH/E9KYrLkXEzRwNrSlQDJa joocha0713@gmail.com";
in
{
  "secrets/llm.env.age".publicKeys = [
    joohoon
  ];
}
