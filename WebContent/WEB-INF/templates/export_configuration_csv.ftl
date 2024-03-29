<html><head>
<style>
    body {
        margin: 0%;
    }

    @font-face {
        font-family: "CG";
        src: url(./resources/CENTURYGOTHIC.ttf) format("truetype");
    }

    textarea {
        margin-left: 0%;
        margin-top: 0%;
        height: 80%;
        width: 100%;
        resize: none;
        visibility: visible;
        background-color: white;
        border-color: black;

    }

    button {
        background-color: white;
        font-family: CG;
        border-color: black;
        border-width: 1px;
        padding-top: 10px;
        padding-bottom: 10px;
        padding-right: 20px;
        padding-left: 20px;
        margin-top: 10px;
        text-transform: capitalize;
    }

</style></head>


<body>
    <b><br/>ID, Model Name, Originator Name, Feature ID, Feature Name, Feature Type, Feature Value, Feature Decision Type, Feature Decision Step, TimeStamp, Recommendation Type</b>
<textarea id="textbox"><#list features as feature> 
${id}, ${modelName}, ${originatorName}, ${feature.id}, ${feature.name}, ${feature.type}, ${feature.value}, ${feature.decisionType}, ${feature.decisionStep}, ${feature.timeStamp}, ${recommendationType}
</#list></textarea>


    <button id="create">SAVE TRACES TO FILE</button>
    <a download="traces.csv" id="downloadlink" style="display: none"><button onclick="functionreset()">DOWNLOAD TRACES</button></a>
    <br>

    <script>
        (function() {
            var textFile = null,
                makeTextFile = function(text) {
                    var data = new Blob([text], {
                        type: 'text/plain'
                    });

                    // If we are replacing a previously generated file we need to
                    // manually revoke the object URL to avoid memory leaks.
                    if (textFile !== null) {
                        window.URL.revokeObjectURL(textFile);
                    }

                    textFile = window.URL.createObjectURL(data);

                    return textFile;
                };


            var create = document.getElementById('create'),
                textbox = document.getElementById('textbox');

            create.addEventListener('click', function() {
                var link = document.getElementById('downloadlink');
                link.href = makeTextFile(textbox.value);
                link.style.display = 'block';
                document.getElementById('create').style.display = 'none';
            }, false);
        })();

        function functionreset() {
            var link = document.getElementById('downloadlink');
            link.style.display = 'none';
            document.getElementById('create').style.display = 'block';
        }

    </script>
    <script>
         document.getElementById("textbox").onchange = function() {functionreset()}
    </script>

<!-- <iframe height=100% width=100%; src=./test.html></iframe>-->
</body></html>