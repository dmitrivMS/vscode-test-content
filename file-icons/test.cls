\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{techreport}[2024/01/15 Technical Report Class]

\LoadClass[11pt,a4paper]{article}

\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{hyperref}

\geometry{margin=1in, headheight=14pt}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\slshape \leftmark}
\fancyhead[R]{\thepage}
\renewcommand{\headrulewidth}{0.4pt}

\newcommand{\reporttitle}[1]{\gdef\@reporttitle{#1}}
\newcommand{\reportauthor}[1]{\gdef\@reportauthor{#1}}
\newcommand{\reportdate}[1]{\gdef\@reportdate{#1}}

\renewcommand{\maketitle}{%
  \begin{center}
    {\LARGE\bfseries \@reporttitle \par}
    \vspace{0.5em}
    {\large \@reportauthor \par}
    \vspace{0.3em}
    {\@reportdate}
  \end{center}
  \vspace{1em}
}
