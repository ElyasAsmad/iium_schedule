var table = document.getElementsByClassName("table table-hover")[0];
var data = table.getElementsByTagName("tr");

var nullIndex = new Array();
var courseCodes = new Array();
var sections = new Array();
var combinedSubjectDatas = new Array();

// section
for (let i = 1; i < data.length; i++) {
    if (data[i].cells[2].firstChild === null) nullIndex.push(i);
    else sections.push(parseInt(data[i].cells[2].innerText));
}

// course code
for (let i = 1; i < data.length; i++) {
    if (!nullIndex.includes(i)) courseCodes.push(data[i].cells[0].innerText);
}

// combine code & section
for (i = 0; i < sections.length; i++) {
    combinedSubjectDatas.push({ courseCode: courseCodes[i], section: sections[i] });
}

var json = JSON.stringify(combinedSubjectDatas);
alert("Copy -----> " + json);
