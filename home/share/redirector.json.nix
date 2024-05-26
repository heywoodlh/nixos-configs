''
{
  "createdBy": "Redirector v3.5.3",
  "createdAt": "2023-05-17T00:00:00.400Z",
  "redirects": [
    {
      "description": "cloudtube",
      "exampleUrl": "https://youtu.be/watch?v=S87CVcPLW00",
      "exampleResult": "http://cloudtube.barn-banana.ts.net/watch?v=S87CVcPLW00",
      "error": null,
      "includePattern": "(https://.*youtube.com|https://youtu.be)/(.*)",
      "excludePattern": "",
      "patternDesc": "Redirect all Youtube links to Cloudtube",
      "redirectUrl": "http://cloudtube.barn-banana.ts.net/$2",
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
      "exampleResult": "http://teddit.barn-banana.ts.net/r/AskReddit/comments/rr5izn/what_is_something_americans_will_never_understand/",
      "error": null,
      "includePattern": "(https://.*reddit.com)/(.*)",
      "excludePattern": "",
      "patternDesc": "Redirect all Reddit links to Teddit",
      "redirectUrl": "http://teddit.barn-banana.ts.net/$2",
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
