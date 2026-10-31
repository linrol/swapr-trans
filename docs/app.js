(function () {
  "use strict";

  const strings = {
    zh: {
      pageTitle: "SwaprTrans · 选词空格即翻，回车原地覆写",
      brandBadge: "原地瞬译",
      navFeatures: "特性",
      navFaq: "常见问题",
      navInstall: "安装",
      navSdk: "开发库",
      navCafe: "咖啡小铺",
      ctaDownload: "下载 DMG",

      // Hero
      eyebrow: "macOS 15+ 官方端侧驱动 · 选词瞬译",
      heroTitle1: "选词空格即翻，",
      heroTitle2: "回车原地覆写。",
      heroSub:
        "在任意聊天框、浏览器或输入区域中划选文字，敲击空格键（默认触发键）瞬起轻盈浮窗；按下回车键，原文原子级蜕变为地道译文！",
      ctaDownloadHero: "下载 SwaprTrans v1.0.2 (DMG)",
      metaChip: " Apple 原生神经引擎",
      metaPrivacy: "100% 隐私·不上云",
      metaWeight: "轻量 < 2MB",

      // Demo Box
      demoTitle: "Teams / Slack 沉浸输入体验",
      editorPlaceholder: "把想去的地方排进每天的行程...",
      pill1: "✍️ 聊天输入 · 原地覆写",
      pill2: "📖 网页浏览 · 划词即翻",
      pill3: "✉️ 商务邮件 · 原地覆写",
      pill4: "💻 终端报错 · 查词对照",

      // Features
      feat1Title: " Apple 官方原生端侧模型",
      feat1Desc:
        "深度集成 macOS 15+ Translation.framework。纯芯片本地神经引擎离线运算，零网络依赖，商业机密与私密沟通 100% 安全。",
      feat2Title: "⚡️ 空格瞬译 · 回车「原地覆写」",
      feat2Desc:
        "消灭多余的鼠标操作与复制粘贴。划选后按空格唤起轻盈浮窗，敲击回车直接替换为地道译文，光标与上下文丝滑保持。",
      feat3Title: "🌐 三引擎智能容灾与自适应",
      feat3Desc:
        "默认 Apple 本地端侧推理；辅以 Microsoft Edge 极速免 Key 通道与 Google Translate 自动无感平滑兜底。",
      feat4Title: "🪟 焦点无损与开源 SwaprTransKit",
      feat4Desc:
        "纯 Swift 原生打造，常驻内存微量。浮窗绝不夺取焦点；核心 SwaprTransKit 作为 Swift Package 完全开源开放。",
      feat5Title: "⭐ 随手收藏与独立生词本",
      feat5Desc:
        "遇到地道用法或生词随手点星收藏。拥有独立原生管理窗口，支持实时双向模糊检索、朗读与一键导出 CSV / JSON。",
      feat6Title: "🗄️ 系统原生 SQLite3 存储",
      feat6Desc:
        "基于 macOS 内置 libsqlite3 驱动，WAL 事务模式，零额外三方包依赖；透明度 40%~100% 自由调节，文字始终锐利。",

      // FAQ
      faqTitle: "常见问题解答 (FAQ)",
      faqSub: "了解 SwaprTrans 的工作原理、隐私安全保障与核心用法",
      faqQ1: "SwaprTrans 的「原地覆写」是如何工作的？",
      faqA1: "在任意聊天框（Teams/Slack/微信）、邮件或终端中输入文字后，划选文字敲击空格键（默认触发键）唤起轻量翻译浮窗；确认译文后轻敲回车键，原文瞬间原子级替换为地道译文，光标与上下文完美保持，无需切屏和反复复制粘贴。",
      faqQ2: "Apple 原生端侧模型是否支持脱网离线翻译？",
      faqA2: "完全支持。在 macOS 15+ (Sequoia) 系统中，SwaprTrans 深度集成了 Apple 官方 Translation.framework 与 Neural Engine 神经引擎。在系统设置中下载本地离线语言包后，完全断网即可秒速离线推理，100% 隐私安全，机密沟通绝不上云。",
      faqQ3: "是否支持修改默认快捷键？",
      faqA3: "支持。默认触发快捷键为空格键（Space），同时在设置面板中预设了右键双击、方向键向下、Option + D、Option + T、Option + Space、F1 ~ F6 等多种高效手势与组合键，用户可按个人习惯自由选择。",
      faqQ4: "第三方开发者如何集成 SwaprTrans？",
      faqA4: "SwaprTrans 的核心能力已拆解封装为 SwaprTransKit，作为 Swift Package (SPM) 完全开源。开发者只需在 Package.swift 中引入依赖，即可在自己的 macOS 原生 App 中开箱即用集成划词瞬译与原地覆写能力。",
      faqQ5: "收藏的生词如何查看、搜索与导出？",
      faqA5: "在菜单栏下拉面板中点击「Saved Translations」即可唤起独立的生词管理窗口。支持对原文与译文进行实时模糊检索、原声发音朗读，并支持一键导出为标准的 CSV 或 JSON 格式，方便无缝同步至 Anki、欧路词典等外部学习工具。",

      // Install
      installTitle: "快速安装与授权",
      installStep1: "下载 <strong>SwaprTrans-1.0.2.dmg</strong> 并将 App 拖拽至 <strong>Applications</strong>；",
      installStep2: "首次打开：若遇 Gatekeeper 提示，在访达中<strong>右键点击 App → 点击「打开」</strong>；",
      installStep3: "按系统提示授予<strong>「辅助功能」(Accessibility)</strong> 权限，即刻开启选词原地覆写体验；",
      installStep4: "若使用 <strong>Apple 原生端侧模型</strong>，系统首次使用会提示下载离线语言包（亦可在 <strong>系统设置 → 通用 → 语言与地区 → 翻译语言</strong> 提前下载），完成后即可完全脱网离线运行。",
      btnDownloadBox: "下载 SwaprTrans-1.0.2.dmg (1.9MB)",

      // Footer & Portal
      footerText: "SwaprTrans · 专为 macOS 打造的极简原生选词瞬译与原地覆写工具",
      footerCafe: "Linrol 的赛博咖啡馆",
      portalText: "来吧台喝杯咖啡",
    },

    en: {
      pageTitle: "SwaprTrans · Select & Space to Translate, Enter to In-Place Rewrite",
      brandBadge: "In-Place",
      navFeatures: "Features",
      navInstall: "Download",
      navSdk: "SPM SDK",
      navFaq: "FAQ",
      navCafe: "Cafe Lounge",
      ctaDownload: "Download DMG",

      // Hero
      eyebrow: "macOS 15+ Native On-Device Engine · Instant Translation",
      heroTitle1: "Space to Translate,",
      heroTitle2: "Enter to In-Place Rewrite.",
      heroSub:
        "Select text anywhere and hit Space (default shortcut) to summon instant translation. Press Enter to atomically rewrite in-place without copy-pasting.",
      ctaDownloadHero: "Download SwaprTrans v1.0.2 (DMG)",
      metaChip: " Apple Native Neural Engine",
      metaPrivacy: "100% Private · On-Device",
      metaWeight: "Lightweight < 2MB",

      // Demo Box
      demoTitle: "Teams / Slack Frictionless Experience",
      editorPlaceholder: "Plan your trip into everyday itinerary...",
      pill1: "✍️ Chat · In-Place Rewrite",
      pill2: "📖 Web · Select to Translate",
      pill3: "✉️ Email · In-Place Rewrite",
      pill4: "💻 Terminal · Error Lookup",

      // Features
      feat1Title: " Apple Official Native Neural Engine",
      feat1Desc:
        "Deeply integrated with macOS 15+ Translation.framework. Computes entirely on local Apple Silicon chips with zero network reliance.",
      feat2Title: "⚡️ Space to Translate · Enter to Rewrite",
      feat2Desc:
        "Eliminates clumsy copy-pasting. Tap Space on selected text to summon HUD, then tap Enter to atomically replace with authentic translation.",
      feat3Title: "🌐 Tri-Engine Smart Failover",
      feat3Desc:
        "Defaults to Apple local offline engine, with seamless fallback to Microsoft Edge fast keyless lane and Google Translate.",
      feat4Title: "🪟 Non-Activating HUD & Open SPM",
      feat4Desc:
        "Pure Swift native build with negligible RAM usage. Never steals window focus; core SwaprTransKit open source via Swift Package.",
      feat5Title: "⭐ Instant Bookmark & Vocabulary Manager",
      feat5Desc:
        "Star authentic expressions directly in the HUD. Access them anytime in a native window with full-text search, TTS, and CSV/JSON export.",
      feat6Title: "🗄️ Native SQLite3 & Frost Density",
      feat6Desc:
        "Powered by macOS built-in libsqlite3 with WAL transactions; customize background opacity 40%–100% with always-crisp typography.",

      // FAQ
      faqTitle: "Frequently Asked Questions (FAQ)",
      faqSub: "Learn how SwaprTrans works, privacy safeguards, and advanced tips",
      faqQ1: "How does SwaprTrans 'In-Place Rewrite' work?",
      faqA1: "Type your draft in any chat box (Teams, Slack, WeChat), email, or terminal. Select the text and press Space to trigger the floating HUD. Tap Enter to atomically replace the original text with fluent translation in-place without copy-pasting.",
      faqQ2: "Does the Apple on-device model support 100% offline translation?",
      faqA2: "Yes. On macOS 15+ (Sequoia), SwaprTrans deeply integrates with Apple's official Translation.framework and Neural Engine. Once the offline language pack is downloaded in macOS System Settings, it translates offline without any internet connection.",
      faqQ3: "Can I customize the trigger shortcut?",
      faqA3: "Yes. Space is the default trigger key. You can also choose from presets including Right Double Click, Down Arrow, Option + D, Option + T, Option + Space, and F1–F6 in the settings panel.",
      faqQ4: "How can developers integrate SwaprTrans in other apps?",
      faqA4: "SwaprTrans core logic is modularized as SwaprTransKit, open sourced via Swift Package Manager. Developers can easily embed in-place translation into their macOS applications.",
      faqQ5: "How to view, search, and export saved translations?",
      faqA5: "Click 'Saved Translations' in the menu bar dropdown to summon the standalone manager. It offers instant bidirectional search, audio pronunciation, and one-click export to CSV or JSON for Anki or vocabulary flashcards.",

      // Install
      installTitle: "Quick Start & Setup",
      installStep1: "Download <strong>SwaprTrans-1.0.2.dmg</strong> and drag the App to <strong>Applications</strong>;",
      installStep2: "First run: if prompted by Gatekeeper, right-click <strong>SwaprTrans.app → Open</strong> in Finder;",
      installStep3: "Grant <strong>Accessibility</strong> permission to allow instant selection detection and in-place rewrite;",
      installStep4: "If using the <strong>Apple Native On-Device engine</strong>, macOS will prompt you to download the offline language pack on first use (or pre-download in <strong>System Settings → General → Language & Region → Translation Languages</strong>). Once downloaded, it operates 100% offline.",
      btnDownloadBox: "Download SwaprTrans-1.0.2.dmg (1.9MB)",

      // Footer & Portal
      footerText: "SwaprTrans · The lightweight native in-place translation tool for macOS",
      footerCafe: "Linrol's Cyber Cafe",
      portalText: "Visit Cafe Lounge",
    },
  };

  const scenarios = [
    // 1. Chat input: In-place rewrite
    {
      mode: "replace",
      theme: "chat",
      appTitle: {
        zh: "Teams / Slack · 输入框原地覆写体验",
        en: "Teams / Slack · In-Place Chat Rewrite"
      },
      zh: {
        prefix: "",
        input: "我的英语不怎么好",
        suffix: "",
        dir: "ZH → EN",
        provider: "Microsoft (Edge)",
        orig: "我的英语不怎么好",
        trans: "My English isn't very good"
      },
      en: {
        prefix: "",
        input: "我的英语不怎么好",
        suffix: "",
        dir: "ZH → EN",
        provider: "Microsoft (Edge)",
        orig: "我的英语不怎么好",
        trans: "My English isn't very good"
      }
    },
    // 2. Web browsing: Select-to-translate & read (no overwrite)
    {
      mode: "read",
      theme: "browser",
      browserUrl: "developer.apple.com/documentation/translation",
      appTitle: {
        zh: "Safari · 网页划词即翻与双语对照",
        en: "Safari · Select to Translate & Lookup"
      },
      zh: {
        prefix: "The M4 chip delivers ",
        input: "industry-leading performance and power efficiency",
        suffix: " across demanding creative workflows.",
        dir: "EN → ZH",
        provider: "Apple (Native)",
        orig: "industry-leading performance and power efficiency",
        trans: "行业领先的超强性能与出色能效表现"
      },
      en: {
        prefix: "The M4 chip delivers ",
        input: "industry-leading performance and power efficiency",
        suffix: " across demanding creative workflows.",
        dir: "EN → ZH",
        provider: "Apple (Native)",
        orig: "industry-leading performance and power efficiency",
        trans: "行业领先的超强性能与出色能效表现"
      }
    },
    // 3. Business Email: In-place rewrite
    {
      mode: "replace",
      theme: "chat",
      appTitle: {
        zh: "Mail / Outlook · 商务邮件草稿原地蜕变",
        en: "Mail / Outlook · Fluent Business Email Rewrite"
      },
      zh: {
        prefix: "",
        input: "期待与贵司团队建立长期稳固的合作关系，共促业务增长。",
        dir: "ZH → EN",
        provider: "Apple (Native)",
        orig: "期待与贵司团队建立长期稳固的合作关系，共促业务增长。",
        trans: "We look forward to establishing a solid partnership with your team to drive mutual growth."
      },
      en: {
        prefix: "",
        input: "期待与贵司团队建立长期稳固的合作关系，共促业务增长。",
        dir: "ZH → EN",
        provider: "Apple (Native)",
        orig: "期待与贵司团队建立长期稳固的合作关系，共促业务增长。",
        trans: "We look forward to establishing a solid partnership with your team to drive mutual growth."
      }
    },
    // 4. Terminal/Docs: Tech term & error lookup (no overwrite)
    {
      mode: "read",
      theme: "terminal",
      terminalPrompt: "linrol@iMac ~ % ",
      appTitle: {
        zh: "Terminal — zsh — 80×24",
        en: "Terminal — zsh — 80×24"
      },
      zh: {
        prefix: "Error: connect ECONNREFUSED — ",
        input: "Check if the backend daemon is actively listening.",
        suffix: "",
        dir: "EN → ZH",
        provider: "Apple (Native)",
        orig: "Check if the backend daemon is actively listening.",
        trans: "检查后台守护进程是否已正常启动并监听端口。"
      },
      en: {
        prefix: "Error: connect ECONNREFUSED — ",
        input: "Check if the backend daemon is actively listening.",
        suffix: "",
        dir: "EN → ZH",
        provider: "Apple (Native)",
        orig: "Check if the backend daemon is actively listening.",
        trans: "检查后台守护进程是否已正常启动并监听端口。"
      }
    }
  ];

  const root = document.documentElement;
  const langButtons = document.querySelectorAll("[data-set-lang]");
  const textStream = document.getElementById("text-stream");
  const swaprHud = document.getElementById("swapr-hud");
  const hudDirText = document.getElementById("hud-dir-text");
  const hudProviderTag = document.getElementById("hud-provider-tag");
  const hudOrigText = document.getElementById("hud-orig-text");
  const hudTransText = document.getElementById("hud-trans-text");
  const hudReplaceBtn = document.getElementById("hud-replace-btn");
  const hudCopyBtn = document.getElementById("hud-copy-btn");
  const hudCopyLabel = document.getElementById("hud-copy-label");
  const demoWindowTitle = document.getElementById("demo-window-title");
  const demoPills = document.querySelectorAll(".demo-pill");

  let currentLang = localStorage.getItem("st-lang") || "zh";
  let activeScenarioIndex = 0;
  let demoTimer = 0;
  let demoToken = 0;

  function t(key) {
    return strings[currentLang][key] ?? strings.zh[key] ?? key;
  }

  function applyLanguage(next) {
    currentLang = next in strings ? next : "zh";
    localStorage.setItem("st-lang", currentLang);
    root.lang = currentLang === "zh" ? "zh-CN" : "en";
    document.title = t("pageTitle");

    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const key = el.getAttribute("data-i18n");
      if (!key) return;
      const value = t(key);
      if (el.getAttribute("data-html") === "true") {
        el.innerHTML = value;
      } else {
        el.textContent = value;
      }
    });

    langButtons.forEach((btn) => {
      btn.setAttribute("aria-pressed", String(btn.getAttribute("data-set-lang") === currentLang));
    });

    restartDemo();
  }

  function sleep(ms, token) {
    return new Promise((resolve, reject) => {
      demoTimer = window.setTimeout(() => {
        if (token !== demoToken) reject(new Error("cancelled"));
        else resolve();
      }, ms);
    });
  }

  function positionHud() {
    if (!swaprHud || !textStream) return;
    const demoBody = document.getElementById("demo-body");
    if (!demoBody) return;
    const targetEl = textStream.querySelector(".text-selected") || textStream;
    const bodyRect = demoBody.getBoundingClientRect();
    const targetRect = targetEl.getBoundingClientRect();

    // Position HUD 10px below the bottom of the selected text to guarantee zero obstruction
    const top = Math.round(targetRect.bottom - bodyRect.top + 10);
    // Align with left edge of selected text, bounded within demo body
    const left = Math.round(Math.max(20, Math.min(targetRect.left - bodyRect.left, bodyRect.width - 340)));

    swaprHud.style.top = `${top}px`;
    swaprHud.style.left = `${left}px`;
  }

  async function runDemo(token) {
    if (!textStream || !swaprHud || !isDemoVisible) return;

    const scene = scenarios[activeScenarioIndex];
    const data = scene[currentLang];

    const demoCard = document.getElementById("demo-card");
    const demoBarTitleWrap = document.getElementById("demo-bar-title-wrap");
    const demoBrowserBar = document.getElementById("demo-browser-bar");
    const browserUrlText = document.getElementById("browser-url-text");
    const terminalPrompt = document.getElementById("terminal-prompt");
    const editorFakeToolbar = document.getElementById("editor-fake-toolbar");
    const terminalFakeStatusbar = document.getElementById("terminal-fake-statusbar");
    const demoCaret = document.getElementById("demo-caret");

    if (demoCard) {
      demoCard.className = `demo-card theme-${scene.theme || "chat"}`;
    }

    if (scene.theme === "browser") {
      if (demoBarTitleWrap) demoBarTitleWrap.style.display = "none";
      if (demoBrowserBar) {
        demoBrowserBar.style.display = "flex";
        if (browserUrlText) browserUrlText.textContent = scene.browserUrl || "developer.apple.com";
      }
      if (terminalPrompt) terminalPrompt.style.display = "none";
      if (editorFakeToolbar) editorFakeToolbar.style.display = "none";
      if (terminalFakeStatusbar) terminalFakeStatusbar.style.display = "none";
      if (demoCaret) demoCaret.style.display = "none";
    } else if (scene.theme === "terminal") {
      if (demoBarTitleWrap) demoBarTitleWrap.style.display = "flex";
      if (demoBrowserBar) demoBrowserBar.style.display = "none";
      if (terminalPrompt) {
        terminalPrompt.style.display = "inline";
        terminalPrompt.textContent = scene.terminalPrompt || "linrol@iMac ~ % ";
      }
      if (editorFakeToolbar) editorFakeToolbar.style.display = "none";
      if (terminalFakeStatusbar) terminalFakeStatusbar.style.display = "flex";
      if (demoCaret) demoCaret.style.display = "none";
    } else {
      if (demoBarTitleWrap) demoBarTitleWrap.style.display = "flex";
      if (demoBrowserBar) demoBrowserBar.style.display = "none";
      if (terminalPrompt) terminalPrompt.style.display = "none";
      if (editorFakeToolbar) editorFakeToolbar.style.display = "flex";
      if (terminalFakeStatusbar) terminalFakeStatusbar.style.display = "none";
      if (demoCaret) demoCaret.style.display = "inline-block";
    }

    if (demoWindowTitle && scene.appTitle) {
      demoWindowTitle.textContent = scene.appTitle[currentLang] || scene.appTitle.zh;
    }

    textStream.innerHTML = "";
    swaprHud.classList.remove("is-visible");
    if (hudReplaceBtn) hudReplaceBtn.classList.remove("active");
    if (hudCopyBtn) {
      hudCopyBtn.classList.remove("active");
      if (hudCopyLabel) hudCopyLabel.textContent = "Copy";
    }

    demoPills.forEach((pill, idx) => {
      pill.classList.toggle("active", idx === activeScenarioIndex);
    });

    try {
      if (scene.mode === "replace") {
        // --- MODE 1: TYPE & REPLACE IN-PLACE ---
        // 1. Type
        for (let i = 1; i <= data.input.length; i++) {
          textStream.textContent = data.input.slice(0, i);
          await sleep(35 + (i % 4 === 0 ? 30 : 0), token);
        }

        await sleep(350, token);

        // 2. Select text (mint green selection highlight)
        textStream.innerHTML = `<span class="text-selected">${data.input}</span>`;
        await sleep(350, token);

        // 3. Float SwaprTrans HUD (Triggered by Space)
        if (hudDirText) hudDirText.textContent = data.dir;
        if (hudProviderTag) hudProviderTag.textContent = data.provider;
        if (hudOrigText) hudOrigText.textContent = data.orig;
        if (hudTransText) hudTransText.textContent = data.trans;
        positionHud();
        swaprHud.classList.add("is-visible");

        await sleep(1400, token);

        // 4. Trigger Replace (Enter key / Replace button)
        if (hudReplaceBtn) hudReplaceBtn.classList.add("active");
        await sleep(220, token);
        if (hudReplaceBtn) hudReplaceBtn.classList.remove("active");

        // 5. In-Place Rewrite
        swaprHud.classList.remove("is-visible");
        textStream.innerHTML = `<span class="text-replaced">${data.trans}</span>`;

        // 6. Pause to appreciate
        await sleep(3500, token);
      } else {
        // --- MODE 2: READING SELECTION TRANSLATE (NO OVERWRITE) ---
        // 1. Full paragraph appears as read-only article / doc
        textStream.innerHTML = `${data.prefix}${data.input}${data.suffix}`;
        await sleep(400, token);

        // 2. Mouse selection highlights target phrase
        textStream.innerHTML = `${data.prefix}<span class="text-selected">${data.input}</span>${data.suffix}`;
        await sleep(400, token);

        // 3. Float SwaprTrans HUD with translation (Triggered by Space)
        if (hudDirText) hudDirText.textContent = data.dir;
        if (hudProviderTag) hudProviderTag.textContent = data.provider;
        if (hudOrigText) hudOrigText.textContent = data.orig;
        if (hudTransText) hudTransText.textContent = data.trans;
        positionHud();
        swaprHud.classList.add("is-visible");

        await sleep(1500, token);

        // 4. User copies translation to clipboard (or just reads it)
        if (hudCopyBtn) {
          hudCopyBtn.classList.add("active");
          if (hudCopyLabel) hudCopyLabel.textContent = "Copied!";
        }
        await sleep(650, token);
        if (hudCopyBtn) hudCopyBtn.classList.remove("active");

        // 5. HUD smoothly fades out, original article text stays completely intact!
        await sleep(400, token);
        swaprHud.classList.remove("is-visible");
        textStream.innerHTML = `${data.prefix}${data.input}${data.suffix}`;

        // 6. Pause to appreciate
        await sleep(3000, token);
      }

      // Next loop
      activeScenarioIndex = (activeScenarioIndex + 1) % scenarios.length;
      if (token === demoToken && isDemoVisible) {
        runDemo(token);
      }
    } catch {
      /* cancelled */
    }
  }

  let isDemoVisible = true;

  function restartDemo() {
    demoToken += 1;
    window.clearTimeout(demoTimer);
    if (isDemoVisible) {
      runDemo(demoToken);
    }
  }

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            if (!isDemoVisible) {
              isDemoVisible = true;
              restartDemo();
            }
          } else {
            isDemoVisible = false;
            demoToken += 1;
            window.clearTimeout(demoTimer);
          }
        });
      },
      { threshold: 0.15 }
    );
    const demoCardEl = document.getElementById("demo-card");
    if (demoCardEl) observer.observe(demoCardEl);
  }

  langButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const next = btn.getAttribute("data-set-lang");
      if (next) applyLanguage(next);
    });
  });

  demoPills.forEach((pill, index) => {
    pill.addEventListener("click", () => {
      activeScenarioIndex = index;
      restartDemo();
    });
  });

  applyLanguage(currentLang);
})();
