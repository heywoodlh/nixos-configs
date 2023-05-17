''
{
  "createdBy": "Redirector v3.5.3",
  "createdAt": "2023-05-17T00:00:00.400Z",
  "redirects": [
    {
      "description": "cloudtube",
      "exampleUrl": "https://youtu.be/watch?v=S87CVcPLW00",
      "exampleResult": "https://cloudtube.heywoodlh.io/watch?v=S87CVcPLW00",
      "error": null,
      "includePattern": "(https://.*youtube.com|https://youtu.be)/(.*)",
      "excludePattern": "",
      "patternDesc": "Redirect all Youtube links to Cloudtube",
      "redirectUrl": "https://cloudtube.heywoodlh.io/$2",
      "patternType": "R",
      "processMatches": "noProcessing",
      "disabled": false,
      "grouped": false,
      "appliesTo": [
        "main_frame"
      ]
    },
    {
      "description": "teddit",
      "exampleUrl": "https://www.reddit.com/r/AskReddit/comments/rr5izn/what_is_something_americans_will_never_understand/",
      "exampleResult": "https://teddit.heywoodlh.io/r/AskReddit/comments/rr5izn/what_is_something_americans_will_never_understand/",
      "error": null,
      "includePattern": "(https://.*reddit.com)/(.*)",
      "excludePattern": "",
      "patternDesc": "Redirect all Reddit links to Teddit",
      "redirectUrl": "https://teddit.heywoodlh.io/$2",
      "patternType": "R",
      "processMatches": "noProcessing",
      "disabled": false,
      "grouped": false,
      "appliesTo": [
        "main_frame"
      ]
    },
    {
      "description": "nitter",
      "exampleUrl": "https://twitter.com/b0rk",
      "exampleResult": "https://nitter.net/b0rk",
      "error": null,
      "includePattern": "(https://.*twitter.com)/(.*)",
      "excludePattern": "",
      "patternDesc": "Redirect all Twitter links to Nitter",
      "redirectUrl": "https://nitter.net/$2",
      "patternType": "R",
      "processMatches": "noProcessing",
      "disabled": false,
      "grouped": false,
      "appliesTo": [
        "main_frame"
      ]
    }
  ]
}
''
