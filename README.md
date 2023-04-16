[OpenAI's Whisper](https://github.com/openai/whisper) a lot better at transcribing speech to text than at translating text, whereas [Google Translate](https://translate.google.com/) is a lot better at translating text than at transcribing speech to text.
So, ideally one would use Whisper to get a transcription and plug that into Google Translate.

In practice, however, it's a little more complicated, because the size of the chunks into which Whisper breaks audio down for transcription seldom correspond to sentences.
The transcript of each chunk is (with greater or lesser success) aligned to its audio using timestamps.
Whisper's output is therefore a mess of partial sentences interspersed with timestamps.
Passing that to Google Translate, will result an attempt to translate each partial sentence (i.e. each audio chunk) as a standalone sentence, with often disastrous consequences for the translation's coherence and accuracy.

One way to solve this, is to painstakingly sift through the transcript by hand, editing it so the aligned chunks correspond to sentences.
But this can easily take some twelve hours per hour of audio.
A somewhat lower quality but much faster solution, would be to split timestamps and transcription line-by-line, then pass the transcription without interspersed timestamps through Google Translate, and finally merge the timestamps and translation again line-by-line, since this process can be automized.

[The first approach](https://github.com/GitWasAMistakeItsNothingButTrash/whisper/tree/approach1) is to install and run Whisper using a bash script; split, translate and merge the output in python using a [Google Translate library](https://pypi.org/project/googletrans/); then burn those subtitles into a copy of the original file using bash again.

[The second approach](https://github.com/GitWasAMistakeItsNothingButTrash/whisper/tree/approach2) is to install and run Whisper using a bash script, split the transcript from the timestamps with python, use the [Google Translate website](https://translate.google.com/?op=docs) to translate, merge the translation with the timestamps using python again, then burn those subtitles into a copy of the original file with bash.
