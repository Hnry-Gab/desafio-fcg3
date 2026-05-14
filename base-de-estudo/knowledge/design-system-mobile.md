# Design System Mobile
<!--
TYPE: knowledge-page
SCOPE: mobile
KEYWORDS: design-system, flutter-theme, cyber-academic, material-3, glassmorphism, dark-mode, light-mode, responsive, breakpoints, montserrat, jetbrains-mono
-->
[TOC]

## Resumo rapido

O app adota linguagem visual Cyber-Academic com Material 3, cores neon, glassmorphism, modo claro/escuro e responsividade para phone, tablet e desktop/web. O tema e centralizado em `mobile/lib/core/theme/`.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mobile
- Fontes: `design ideas/DESIGN.md`, `mobile/lib/core/theme/`, `mobile/lib/core/responsive/`, `mobile/lib/shared/widgets/`
- Plataforma: Flutter

## Keywords

- design-system
- flutter-theme
- cyber-academic
- material-3
- glassmorphism
- neon
- dark-mode
- light-mode
- responsive
- breakpoints
- montserrat
- jetbrains-mono
- navigation-rail
- bottom-navigation

## Contexto

O visual precisa diferenciar a plataforma de layouts genericos e funcionar para aluno e staff/provider. A mesma base deve se adaptar a mobile e web.

## Detalhamento tecnico

Elementos evidenciados:

- `app_theme.dart`: tema Material 3.
- `app_colors.dart`: paleta e tokens de cor.
- `theme_provider.dart`: persistencia de modo de tema.
- `breakpoints.dart`: phone, tablet e desktop.
- `glass_bottom_nav.dart`: navegacao inferior customizada.
- `client_shell.dart` e `staff_shell.dart`: alternam entre bottom nav e NavigationRail conforme tela.

## Fluxo / Arquitetura

```text
ThemeProvider -> AppTheme -> widgets compartilhados
Breakpoints -> shell responsivo -> bottom nav ou navigation rail
```

## Interfaces e dependencias

- Phone: largura menor que 600dp.
- Tablet: 600 a 1023dp.
- Desktop: 1024dp ou mais.
- Fontes planejadas/evidenciadas: Montserrat e JetBrains Mono.

## Exemplos

Padrao de navegacao responsiva:

```text
phone -> GlassBottomNav
tablet/desktop -> NavigationRail
```

## Links relacionados

- [Mobile Flutter](mobile-flutter.md)
- [ADR 007 - Flutter com Riverpod e GoRouter](../adr/007-flutter-riverpod-gorouter.md)
- [Estudo - Flutter no projeto](../study-guides/estudo-flutter-projeto.md)
