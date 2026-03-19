(function() {
  function clamp(value, min, max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  function useScanSequence(messages, durationMs, intervalMs) {
    var indexState = React.useState(0);
    var index = indexState[0];
    var setIndex = indexState[1];
    var scanningState = React.useState(true);
    var scanning = scanningState[0];
    var setScanning = scanningState[1];

    React.useEffect(function() {
      var intervalId = window.setInterval(function() {
        setIndex(function(prev) {
          return (prev + 1) % messages.length;
        });
      }, intervalMs);

      var timeoutId = window.setTimeout(function() {
        setScanning(false);
      }, durationMs);

      return function() {
        window.clearInterval(intervalId);
        window.clearTimeout(timeoutId);
      };
    }, [messages.length, durationMs, intervalMs]);

    return {
      scanning: scanning,
      message: messages[index]
    };
  }

  function ScoreGauge(props) {
    var score = clamp(props.score || 0, 0, 100);
    var progressState = React.useState(0);
    var progress = progressState[0];
    var setProgress = progressState[1];
    var radius = 92;
    var circumference = 2 * Math.PI * radius;
    var offset = circumference - (progress / 100) * circumference;

    React.useEffect(function() {
      var id = window.requestAnimationFrame(function() {
        setProgress(score);
      });
      return function() {
        window.cancelAnimationFrame(id);
      };
    }, [score]);

    return (
      <div className="score-gauge">
        <svg width="240" height="240" viewBox="0 0 240 240" aria-hidden="true">
          <defs>
            <linearGradient id="scoreGradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#4de5ff" />
              <stop offset="60%" stopColor="#ff4bd8" />
              <stop offset="100%" stopColor="#b7ff2a" />
            </linearGradient>
          </defs>
          <circle
            className="score-track"
            cx="120"
            cy="120"
            r={radius}
            strokeWidth="14"
            fill="none"
          />
          <circle
            className="score-progress"
            cx="120"
            cy="120"
            r={radius}
            strokeWidth="14"
            fill="none"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
          />
        </svg>
        <div className="score-center">
          <div className="score-value">{Math.round(progress)}</div>
          <div className="score-label">Signal Score</div>
        </div>
      </div>
    );
  }

  function ToneToggle(props) {
    return (
      <div className="tone-toggle" role="group" aria-label="Tone mode">
        <button
          type="button"
          className={"tone-button" + (props.tone === "normal" ? " is-active" : "")}
          onClick={function() { props.onChange("normal"); }}
        >
          Normal Mode
        </button>
        <button
          type="button"
          className={"tone-button" + (props.tone === "roast" ? " is-active" : "")}
          onClick={function() { props.onChange("roast"); }}
        >
          Roast Mode
        </button>
      </div>
    );
  }

  function ScoreBreakdown(props) {
    var categories = props.categories || [];
    var readyState = React.useState(false);
    var ready = readyState[0];
    var setReady = readyState[1];

    React.useEffect(function() {
      var id = window.requestAnimationFrame(function() {
        setReady(true);
      });
      return function() {
        window.cancelAnimationFrame(id);
      };
    }, []);

    return (
      <div className={"breakdown" + (ready ? " is-ready" : "")}
        role="group"
        aria-label="Category signal breakdown"
      >
        <div className="section-title">Category Signal</div>
        {categories.map(function(item) {
          var score = clamp(item.score || 0, 0, 100);
          return (
            <div className="breakdown-row" key={item.name}>
              <div className="breakdown-meta">
                <div className="breakdown-name">{item.name}</div>
                <div className="breakdown-score">{score}</div>
              </div>
              <div className="breakdown-bar">
                <span className="breakdown-fill" style={{ "--target": score + "%" }}></span>
              </div>
              <div className="breakdown-hint">{item.hint}</div>
            </div>
          );
        })}
      </div>
    );
  }

  function BadgeRack(props) {
    var badges = props.badges || [];
    return (
      <div className="badge-rack" role="group" aria-label="Unlocked badges">
        <div className="section-title">Badges</div>
        <div className="badge-grid">
          {badges.map(function(badge) {
            var description = badge.unlocked ? badge.description : badge.hint;
            return (
              <div
                key={badge.name}
                className={"badge " + (badge.unlocked ? "unlocked" : "locked")}
                title={description}
              >
                <div className="badge-name">{badge.name}</div>
                <div className="badge-desc">{description}</div>
              </div>
            );
          })}
        </div>
      </div>
    );
  }

  function ScoreReport(props) {
    // Lightweight client-side scan simulation for fun feedback.
    var scanMessages = [
      "Crawling DOM...",
      "Reading metadata...",
      "Checking technical signals...",
      "Detecting ranking anomalies...",
      "Calibrating SEO score..."
    ];
    var scan = useScanSequence(scanMessages, 1700, 420);
    var toneState = React.useState("normal");
    var tone = toneState[0];
    var setTone = toneState[1];
    var copyState = React.useState("Copy share text");
    var copyLabel = copyState[0];
    var setCopyLabel = copyState[1];
    var summary = tone === "roast" ? props.roast_summary : props.summary;
    var highlights = tone === "roast" ? props.roast_highlights : props.highlights;
    var shareText = "I scored " + Math.round(props.score) + "/100 on SEO Signal Console - " + props.rank + ".";

    function copyShareText() {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(shareText).then(function() {
          setCopyLabel("Copied");
          window.setTimeout(function() { setCopyLabel("Copy share text"); }, 1200);
        });
        return;
      }

      var textarea = document.createElement("textarea");
      textarea.value = shareText;
      textarea.setAttribute("readonly", "");
      textarea.style.position = "absolute";
      textarea.style.left = "-9999px";
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand("copy");
      document.body.removeChild(textarea);
      setCopyLabel("Copied");
      window.setTimeout(function() { setCopyLabel("Copy share text"); }, 1200);
    }

    if (scan.scanning) {
      return (
        <div className="scan-panel" role="status" aria-live="polite">
          <div className="scan-title">Scanning...</div>
          <div className="scan-message">{scan.message}</div>
          <div className="scan-dots" aria-hidden="true">
            <span></span><span></span><span></span>
          </div>
        </div>
      );
    }

    return (
      <div className="score-report is-ready">
        <div className="score-report-top">
          <div className="score-panel">
            <ScoreGauge score={props.score} />
            <div className="rank-pill" aria-label="Rank">{props.rank}</div>
          </div>
          <div>
            <div className="section-title">Signal Status</div>
            <h3>{props.rank}</h3>
            <p className="score-summary">{summary}</p>
            <ToneToggle tone={tone} onChange={setTone} />
            {highlights.length > 0 && (
              <ul className="score-highlights">
                {highlights.map(function(item, index) {
                  return <li key={index}>{item}</li>;
                })}
              </ul>
            )}
            <div className="share-row">
              <div className="share-text">{shareText}</div>
              <button type="button" className="button ghost" onClick={copyShareText}>
                {copyLabel}
              </button>
            </div>
          </div>
        </div>
        <div className="score-report-bottom">
          <ScoreBreakdown categories={props.categories} />
          <BadgeRack badges={props.badges} />
        </div>
      </div>
    );
  }

  window.ScoreReport = ScoreReport;
})();
