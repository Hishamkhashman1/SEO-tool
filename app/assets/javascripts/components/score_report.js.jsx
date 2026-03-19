(function() {
  function clamp(value, min, max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
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
            return (
              <div
                key={badge.name}
                className={"badge " + (badge.unlocked ? "unlocked" : "locked")}
                title={badge.description}
              >
                <div className="badge-name">{badge.name}</div>
                <div className="badge-desc">{badge.description}</div>
              </div>
            );
          })}
        </div>
      </div>
    );
  }

  function ScoreReport(props) {
    var highlights = props.highlights || [];
    return (
      <div className="score-report">
        <div className="score-report-top">
          <ScoreGauge score={props.score} />
          <div>
            <div className="section-title">Signal Status</div>
            <h3>{props.tier}</h3>
            <p className="score-summary">{props.summary}</p>
            {highlights.length > 0 && (
              <ul className="score-highlights">
                {highlights.map(function(item, index) {
                  return <li key={index}>{item}</li>;
                })}
              </ul>
            )}
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
