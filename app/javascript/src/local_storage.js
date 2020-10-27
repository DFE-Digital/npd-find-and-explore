function getFromLocalStorage(listName) {
  if (!listName) {
    return
  }

  var list = localStorage.getItem(listName)
  return (list ? JSON.parse(localStorage.getItem(listName)) : {})
}

function addToLocalStorage(listName, id, name, value) {
  if (!listName || !id) {
    return
  }

  var list = getFromLocalStorage(listName)
  list[id][name] = value
  localStorage.setItem(listName, JSON.stringify(list))
}

function toggleFromList(event) {
  var element = event.currentTarget;
  var listName = element.dataset.saveToLocalStorage;
  var list = getFromLocalStorage(listName);

  if (!element.checked) {
    delete list[element.id]
  } else if (!list[element.id]) {
    list[element.id] = element.dataset;
  }
  localStorage.setItem(listName, JSON.stringify(list))
}

export { getFromLocalStorage, addToLocalStorage, toggleFromList }
