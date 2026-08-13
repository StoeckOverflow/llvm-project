#ifndef WHERE_PARAMETERS_TEMPLATE_DEPENDENT_MEMBER_TYPE_H
#define WHERE_PARAMETERS_TEMPLATE_DEPENDENT_MEMBER_TYPE_H

template <typename Container> void f(const typename Container::value_type &);

#endif
