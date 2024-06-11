import React, { useState } from "react";
import { messageTemplate } from "../messageTemplate";

const categories = [
  "Characters",
  "Objects",
  "Techniques",
  "Actions",
  "Geography",
  "Orientation",
  "Musings",
];

const MessageBuilder = ({ onMessageConstructed }) => {
  const [templateIndex, setTemplateIndex] = useState(0);
  const [categoryIndex, setCategoryIndex] = useState(0);
  const [wordIndex, setWordIndex] = useState(0);

  const handleTemplateChange = (e) => {
    const index = parseInt(e.target.value);
    setTemplateIndex(index);
    if (!messageTemplate.templates[index].includes("****")) {
      setCategoryIndex(0);
      setWordIndex(0);
    }
    onMessageConstructed([index, categoryIndex, wordIndex]);
  };

  const handleCategoryChange = (e) => {
    const index = parseInt(e.target.value);
    setCategoryIndex(index);
    setWordIndex(0);
    onMessageConstructed([templateIndex, index, 0]);
  };

  const handleWordChange = (e) => {
    const index = parseInt(e.target.value);
    setWordIndex(index);
    onMessageConstructed([templateIndex, categoryIndex, index]);
  };

  return (
    <div className="message-builder-container">
      <p>Build your Message</p>
      <label>
        Template:
        <select value={templateIndex} onChange={handleTemplateChange}>
          {messageTemplate.templates.map((template, index) => (
            <option value={index} key={index}>
              {template.replace("****", "___")}
            </option>
          ))}
        </select>
      </label>

      {messageTemplate.templates[templateIndex].includes("****") && (
        <>
          <label>
            Category:
            <select value={categoryIndex} onChange={handleCategoryChange}>
              {Object.keys(messageTemplate.categories).map(
                (categoryKey, index) => (
                  <option value={categoryKey} key={index}>
                    {categories[categoryKey]}
                  </option>
                ),
              )}
            </select>
          </label>
          <label>
            Word:
            <select value={wordIndex} onChange={handleWordChange}>
              {messageTemplate.categories[categoryIndex].map((word, index) => (
                <option value={index} key={index}>
                  {word}
                </option>
              ))}
            </select>
          </label>
        </>
      )}
    </div>
  );
};

export default MessageBuilder;
