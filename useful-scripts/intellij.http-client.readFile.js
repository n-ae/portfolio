// ### to be run in https://github.com/mozilla/rhino
const FileReader = java.io.FileReader;
const BufferedReader = java.io.BufferedReader;

export default function readFile(filePath) {
	const reader = new BufferedReader(new FileReader(filePath));
	let line;
	let content = "";
	while ((line = reader.readLine()) !== null) {
		content += line;
	}
	reader.close();
	return JSON.parse(content);
}


// ### call it in the pre/post script in .http ###
// import readFile from './readFile.js';
// client.global.set("CREATE_DATA", readFile('create-data.json'));


// ### run the .http test
// docker run --rm -i -t -v $PWD:/workdir jetbrains/intellij-http-client --js=Rhino -p my_tests.http
