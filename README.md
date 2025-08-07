# Doom Emacs Configuration with AI Code Assistant

[![Doom Emacs CI](https://github.com/ripple0328/.doom.d/actions/workflows/ci.yml/badge.svg)](https://github.com/ripple0328/.doom.d/actions/workflows/ci.yml)

A **literate Doom Emacs configuration** with integrated **AI Code Assistant** powered by gptel. This setup provides a portable, testable Emacs environment with comprehensive coding assistance workflows.

## 🚀 Quick Installation

```bash
# Install Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# Clone this configuration
git clone --depth 1 https://github.com/ripple0328/doom ~/.config/doom

# (optional) Install system dependencies
brew install hunspell
brew install hunspell-en
# Install and sync
~/.config/emacs/bin/doom install 
doom sync            # tangle & install packages
```

Open Emacs and enjoy a secure, reproducible setup with AI assistance!

## ⚡ AI Code Assistant

This configuration includes a comprehensive **AI Code Assistant** powered by gptel and your local LM Studio server. The assistant provides specialized workflows for different coding tasks with dedicated keybindings and expert personas.

### **Quick Start**

1. **Start LM Studio** with the `openai/gpt-oss-20b` model on `localhost:1234`
2. **Restart Emacs** after running `doom sync`
3. **Begin coding** - the assistant is ready to help!

### **Keybindings Reference**

#### **Leader Key Shortcuts** (`SPC l` - LLM Assistant)
- `SPC l c` - Open gptel chat
- `SPC l s` - Send selection to AI  
- `SPC l m` - Open gptel menu (change model/settings)
- `SPC l r` - Rewrite/refactor code
- `SPC l a` - Add context (region/buffer)
- `SPC l f` - Add file to context

#### **Code Assistant Shortcuts** (`SPC l o` - Code Assistant)
- `SPC l o r` - **Code Review** - Get detailed code review
- `SPC l o e` - **Explain Code** - Get code explanation  
- `SPC l o f` - **Refactor Code** - Interactive code refactoring
- `SPC l o d` - **Debug Help** - Get debugging assistance
- `SPC l o o` - **Optimize** - Get performance suggestions
- `SPC l o t` - **Write Tests** - Generate test cases
- `SPC l o s` - **Coding Session** - Start full session with project context
- `SPC l o p` - **Add Project Context** - Add key project files

#### **Local Leader** (In programming modes: `, {key}`)
- `, r` - Code review
- `, e` - Explain code
- `, f` - Refactor
- `, d` - Debug help
- `, o` - Optimize
- `, t` - Write tests

### **Common Workflows**

#### **1. Code Review Workflow**
```
1. Select problematic code
2. Press `SPC l o r` (or `, r`)
3. Get detailed review with suggestions
4. Apply suggested changes
```

#### **2. Refactoring Workflow** 
```
1. Select code to refactor
2. Press `SPC l o f` (or `, f`) 
3. Preview changes in diff mode
4. Accept, edit, or iterate on changes
```

#### **3. Full Project Analysis**
```
1. Press `SPC l o s` (coding session)
   - Automatically adds project context (package.json, README, etc.)
   - Opens dedicated chat buffer
2. Ask project-wide questions with full context
```

#### **4. Debug Assistance**
```
1. Select error message or problematic code
2. Press `SPC l o d` (or `, d`)
3. Get debugging strategies and solutions
```

#### **5. Test Generation**
```
1. Select function/class to test
2. Press `SPC l o t` (or `, t`)
3. Get comprehensive test cases
```

### **AI Specialist Personas**

The assistant automatically switches between specialized personas:

- **Code Review**: Senior engineer focused on quality, security, performance
- **Explain Code**: Educational expert that breaks down complex concepts  
- **Refactor**: Refactoring specialist focused on clean code principles
- **Debug**: Debugging expert that identifies root causes
- **Optimize**: Performance expert focused on efficiency
- **Test**: Testing expert that writes comprehensive test suites

### **Pro Tips**

1. **Start sessions with context**: Use `SPC l o s` to automatically load project files
2. **Chain workflows**: Review → Refactor → Test → Optimize
3. **Use project context**: `SPC l o p` adds key project files to every conversation
4. **Iterate on suggestions**: Use `SPC l m` to adjust temperature/parameters
5. **Save good prompts**: The system prompts are customizable in `config.org`

### **Example Complete Session**

```
1. Open a Python file with a complex function
2. SPC l o s (start coding session - loads project context)
3. Select the function
4. , e (explain what this function does)
5. , r (review for potential issues)  
6. , f (refactor based on suggestions)
7. , t (generate tests for the refactored code)
8. , o (optimize if needed)
```

## 🔧 Configuration

The code assistant configuration is defined in `config.org` under the **AI/LLM Integration** section. Key components:

- **Backend**: Local LM Studio server (`localhost:1234`)
- **Model**: `openai/gpt-oss-20b` 
- **System Prompts**: Specialized directives for each workflow
- **Context Management**: Automatic project file detection
- **Keybindings**: Both leader key and local leader mappings

## 📖 Documentation

For detailed development information, testing, and technical details, see [DEVELOPMENT.md](./DEVELOPMENT.md).
