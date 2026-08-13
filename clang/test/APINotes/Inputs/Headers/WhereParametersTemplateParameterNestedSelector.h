#ifndef WHERE_PARAMETERS_TEMPLATE_PARAMETER_NESTED_SELECTOR_H
#define WHERE_PARAMETERS_TEMPLATE_PARAMETER_NESTED_SELECTOR_H

template <typename T> struct Outer {
  template <typename U, typename V, typename W> void makeWidget(W);
};

#endif
