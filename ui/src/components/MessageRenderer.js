import React from "react";
import { messageTemplate } from "../messageTemplate";

const MessageRenderer = ({ indices }) => {
  const [templateIndex, categoryIndex, wordIndex] = indices;

  const template = messageTemplate.templates[templateIndex];
  const category = messageTemplate.categories[categoryIndex];
  const word = category ? category[wordIndex] : "";

  const message = template.includes("****")
    ? template.replace("****", word)
    : template;

  return (
    <div
      style={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        borderRadius: "50%",
        width: "100%",
        height: "100%",
      }}
    >
      <p
        style={{
          fontFamily: '"Tiny5", sans-serif',
          textAlign: "center",
          fontSize: 12,
          padding: 0,
          margin: 0,
        }}
      >
        {message}
      </p>
    </div>
  );
};

export default MessageRenderer;
