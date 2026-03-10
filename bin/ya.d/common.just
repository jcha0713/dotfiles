ROOT := justfile_directory() / ".."
_hostname := `hostname -s`
flake_host := env_var_or_default("FLAKE_HOST",
  if _hostname == "jcha-think" {
   "think" 
  } else if _hostname == "jcha-mini" {
   "mini" 
  } else {
   _hostname 
  }
)
