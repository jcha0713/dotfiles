package main

import (
	"crypto/rand"
	_ "embed"
	"errors"
	"fmt"
	"math/big"
	"os"
	"path/filepath"
	"strings"
)

//go:embed defaults/languages.txt
var defaultLanguages string

const usage = `Usage:
  rou spin [--exclude rust,go]
  rou add <language>
  rou remove <language>
  rou list
  rou history`

var errNoLanguages = errors.New("no languages configured")

type paths struct {
	languages string
	history   string
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintf(os.Stderr, "rou: %v\n", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 || args[0] == "help" || args[0] == "--help" || args[0] == "-h" {
		fmt.Println(usage)
		return nil
	}

	p, err := rouPaths()
	if err != nil {
		return err
	}

	switch args[0] {
	case "spin":
		exclude, err := parseSpinArgs(args[1:])
		if err != nil {
			return err
		}
		languages, _, err := loadLanguages(p)
		if err != nil {
			return err
		}
		available := filterExcluded(languages, exclude)
		if len(available) == 0 {
			return errors.New("no languages available after exclusions")
		}
		choice, err := pick(available)
		if err != nil {
			return err
		}
		fmt.Println(choice)
		return appendHistory(p, choice)
	case "add":
		name := strings.TrimSpace(strings.Join(args[1:], " "))
		if name == "" {
			return usageError("add requires a language name")
		}
		return addLanguage(p, name)
	case "remove":
		name := strings.TrimSpace(strings.Join(args[1:], " "))
		if name == "" {
			return usageError("remove requires a language name")
		}
		return removeLanguage(p, name)
	case "list":
		if len(args) != 1 {
			return usageError("list takes no arguments")
		}
		languages, _, err := loadLanguages(p)
		if err != nil {
			return err
		}
		for _, language := range languages {
			fmt.Println(language)
		}
		return nil
	case "history":
		if len(args) != 1 {
			return usageError("history takes no arguments")
		}
		items, err := readHistory(p)
		if err != nil {
			return err
		}
		for _, item := range items {
			fmt.Println(item)
		}
		return nil
	default:
		return usageError("unknown command: " + args[0])
	}
}

func usageError(message string) error {
	return fmt.Errorf("%s\n\n%s", message, usage)
}

func rouPaths() (paths, error) {
	languagesPath := os.Getenv("ROU_LANGUAGES_FILE")
	if languagesPath == "" {
		configDir, err := xdgDir("XDG_CONFIG_HOME", ".config")
		if err != nil {
			return paths{}, err
		}
		languagesPath = filepath.Join(configDir, "rou", "languages.txt")
	}

	stateDir, err := xdgDir("XDG_STATE_HOME", filepath.Join(".local", "state"))
	if err != nil {
		return paths{}, err
	}

	return paths{
		languages: languagesPath,
		history:   filepath.Join(stateDir, "rou", "history.txt"),
	}, nil
}

func xdgDir(envName, fallback string) (string, error) {
	if value := os.Getenv(envName); value != "" {
		return value, nil
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, fallback), nil
}

func loadLanguages(p paths) ([]string, []string, error) {
	if err := os.MkdirAll(filepath.Dir(p.languages), 0o755); err != nil {
		return nil, nil, err
	}
	if _, err := os.Stat(p.languages); errors.Is(err, os.ErrNotExist) {
		if err := os.WriteFile(p.languages, []byte(defaultLanguages), 0o644); err != nil {
			return nil, nil, err
		}
	} else if err != nil {
		return nil, nil, err
	}

	body, err := os.ReadFile(p.languages)
	if err != nil {
		return nil, nil, err
	}
	lines := splitLines(string(body))
	seen := map[string]bool{}
	languages := make([]string, 0, len(lines))
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		key := strings.ToLower(trimmed)
		if seen[key] {
			return nil, nil, fmt.Errorf("duplicate language in languages file: %s", trimmed)
		}
		seen[key] = true
		languages = append(languages, trimmed)
	}
	if len(languages) == 0 {
		return nil, lines, errNoLanguages
	}
	return languages, lines, nil
}

func splitLines(text string) []string {
	text = strings.ReplaceAll(text, "\r\n", "\n")
	text = strings.TrimSuffix(text, "\n")
	if text == "" {
		return nil
	}
	return strings.Split(text, "\n")
}

func parseSpinArgs(args []string) (map[string]bool, error) {
	exclude := map[string]bool{}
	for i := 0; i < len(args); i++ {
		arg := args[i]
		switch {
		case arg == "--exclude":
			if i+1 >= len(args) {
				return nil, usageError("--exclude requires a value")
			}
			for _, item := range strings.Split(args[i+1], ",") {
				if item = strings.ToLower(strings.TrimSpace(item)); item != "" {
					exclude[item] = true
				}
			}
			i++
		case strings.HasPrefix(arg, "--exclude="):
			for _, item := range strings.Split(strings.TrimPrefix(arg, "--exclude="), ",") {
				if item = strings.ToLower(strings.TrimSpace(item)); item != "" {
					exclude[item] = true
				}
			}
		default:
			return nil, usageError("unexpected argument: " + arg)
		}
	}
	return exclude, nil
}

func filterExcluded(languages []string, exclude map[string]bool) []string {
	if len(exclude) == 0 {
		return languages
	}
	available := make([]string, 0, len(languages))
	for _, language := range languages {
		if !exclude[strings.ToLower(language)] {
			available = append(available, language)
		}
	}
	return available
}

func pick(languages []string) (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(int64(len(languages))))
	if err != nil {
		return "", err
	}
	return languages[n.Int64()], nil
}

func addLanguage(p paths, name string) error {
	languages, _, err := loadLanguages(p)
	if err != nil && !errors.Is(err, errNoLanguages) {
		return err
	}
	for _, language := range languages {
		if strings.EqualFold(language, name) {
			return nil
		}
	}
	f, err := os.OpenFile(p.languages, os.O_APPEND|os.O_WRONLY, 0o644)
	if err != nil {
		return err
	}
	defer f.Close()
	body, err := os.ReadFile(p.languages)
	if err != nil {
		return err
	}
	prefix := ""
	if len(body) > 0 && body[len(body)-1] != '\n' {
		prefix = "\n"
	}
	_, err = f.WriteString(prefix + name + "\n")
	return err
}

func removeLanguage(p paths, name string) error {
	_, lines, err := loadLanguages(p)
	if err != nil && !errors.Is(err, errNoLanguages) {
		return err
	}
	removed := false
	next := make([]string, 0, len(lines))
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed != "" && !strings.HasPrefix(trimmed, "#") && strings.EqualFold(trimmed, name) {
			removed = true
			continue
		}
		next = append(next, line)
	}
	if !removed {
		return fmt.Errorf("language not found: %s", name)
	}
	body := ""
	if len(next) > 0 {
		body = strings.Join(next, "\n") + "\n"
	}
	return os.WriteFile(p.languages, []byte(body), 0o644)
}

func appendHistory(p paths, choice string) error {
	if err := os.MkdirAll(filepath.Dir(p.history), 0o755); err != nil {
		return err
	}
	f, err := os.OpenFile(p.history, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = f.WriteString(choice + "\n")
	return err
}

func readHistory(p paths) ([]string, error) {
	body, err := os.ReadFile(p.history)
	if errors.Is(err, os.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	items := splitLines(string(body))
	out := make([]string, 0, len(items))
	for _, item := range items {
		if item != "" {
			out = append(out, item)
		}
	}
	return out, nil
}
